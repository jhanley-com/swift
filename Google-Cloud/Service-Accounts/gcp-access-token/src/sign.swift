/*****************************************************************************
* Date Created: 2022-12-14
* Last Update:  2022-12-14
* https://www.jhanley.com
* Copyright (c) 2020, John J. Hanley
* Author: John J. Hanley
* License: MIT
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*****************************************************************************/

import Foundation

func sign_rsa_sha256_pkey_file(data: Data, filename: String, signature: inout Data) -> Int {
	var ret: Int32 = -1

	data.withUnsafeBytes{ (unsafeBytes) in
		let bytes = unsafeBytes.bindMemory(to: UInt8.self).baseAddress!

		var sig = [UInt8](repeating: 0, count: 256)

		var slen = sig.count

		ret = openssl_sign_rsa_sha256_pkey_file(
						bytes,
						unsafeBytes.count,
						filename,
						&sig,
						&slen)

		var index = 0
		for val in sig {
			signature[index] = val
			index += 1
		}
	}

	return Int(ret)
}

func sign_rsa_sha256_pkey_string(data: Data, pkey: String, signature: inout Data) -> Int {
	var ret: Int32 = -1

	data.withUnsafeBytes{ (unsafeBytes) in
		let bytes = unsafeBytes.bindMemory(to: UInt8.self).baseAddress!

		var sig = [UInt8](repeating: 0, count: 256)

		var slen = sig.count

		ret = openssl_sign_rsa_sha256_pkey_string(
						bytes,
						unsafeBytes.count,
						pkey,
						Int32(pkey.count),
						&sig,
						&slen)

		var index = 0
		for val in sig {
			signature[index] = val
			index += 1
		}
	}

	return Int(ret)
}

func sign(service_account_file: String, input: Data, output: String?, format: String) -> Int {
	// service_account_file	Service Account JSON key filename
	// input		data to be signed.
	// output		filename to write signature file. If nil, write to stdout
	// format  		base64 (default), base64url, hex

	guard let json = getServiceAccountJson(filename: service_account_file) else {
		// ErrorText("Error: Cannot decode service account JSON key")
		return -1
	}

	// The PEM string must use UNIX line endings (LF) and not DOS/Windows (CR-LF)
	// let privateKey = json.private_key
	let privateKey = json.private_key.replacingOccurrences(of: "\r\n", with: "\n")

	// Signature is 256 bytes for 2048 key
	var signature = Data(count: 256)

	let ret = sign_rsa_sha256_pkey_string(data: input, pkey: privateKey, signature: &signature)

	if ret != 0 {
		ErrorText("ret: \(ret)")
		return -1
	}

	if arg_debug {
		DebugText("Signature:")
		print_hex(signature, 0, Int64(signature.count))
	}

	var value = ""

	switch format {
	case "base64":
		value = signature.base64EncodedString()
	case "base64url":
		let b64 = signature.base64EncodedString()
		value = base64ToBase64url(base64: b64)
	case "hex":
		value = binaryToHex(data: signature)
	default:
		value = signature.base64EncodedString()
	}

	let b64 = signature.base64EncodedString()

	if arg_debug {
		DebugText("")
		DebugText("Base64 Signature:")
		DebugText(b64)
	}

	let sig = SignatureFile(
		private_key_id: json.private_key_id,
		client_x509_cert_url: json.client_x509_cert_url,
		format: format,
		signature: value)

	var outdata: String? = nil

	do {
		let encoder = JSONEncoder()

		// base64 has sequences with "/" chars, so we must use .withoutEscapingSlashes
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

		let data = try encoder.encode(sig)
		guard let s = String(data: data, encoding: .utf8) else {
			ErrorText("Error: Cannot convert data to string")
			return -1
		}

		// let s = _s.replacingOccurrences(of: "\\/", with: "/")

		outdata = s
	}
	catch {
		ErrorText("Error: Cannot encode signature file")
		return -1
	}

	guard let outdata else {
		ErrorText("Error: Cannot encode signature file")
		return -1
	}

	guard let output else {
		// This is not an error. Write the signature to stdout
		print(outdata)
		return 0
	}

	if arg_debug {
		DebugText("")
		DebugText("JSON Signature")
		DebugText(outdata)
	}

	do {
		print("Writing signature to \(output)")
		try outdata.write(toFile: output, atomically: false, encoding: .utf8)
	}
	catch {
		ErrorText(error.localizedDescription)
		ErrorText("Error: Cannot write signature file")
		return -1
	}

	return 0
}
