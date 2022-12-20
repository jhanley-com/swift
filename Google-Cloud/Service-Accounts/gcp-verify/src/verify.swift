/*****************************************************************************
* Date Created: 2022-12-12
* Last Update:  2022-12-19
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
#if !os(macOS)
import FoundationNetworking	// This is required for Linux, does not exist on macOS
#endif

func verify_rsa_sha256_pubkey_string(data: Data, pubkey: String, signature: Data) -> Int {
	var ret: Int32 = -1

	data.withUnsafeBytes{ (unsafeBytes) in
		let bytes = unsafeBytes.bindMemory(to: UInt8.self).baseAddress!

		signature.withUnsafeBytes{ (unsafeBytes2) in
			let bytes2 = unsafeBytes2.bindMemory(to: UInt8.self).baseAddress!

			ret = openssl_verify_rsa_sha256_pubkey_string(
							bytes,
							unsafeBytes.count,
							pubkey,
							Int32(pubkey.count),
							bytes2,
							unsafeBytes2.count)
		}
	}

	return Int(ret)
}

func verify(signature_filename: String, input: Data) -> Int {
	// service_account_file	Service Account JSON key filename
	// input		data to be verified.

	guard let sig = readSignatureFile(filename: signature_filename) else {
		return -1
	}

	if arg_debug {
		DebugText("Private Key ID: \(sig.private_key_id)")
		DebugText("Signature Format: \(sig.format)")
		DebugText("Signature: \(sig.signature)")
	}

	guard let cert = GetPublicCertificate(cert_url: sig.client_x509_cert_url, private_key_id: sig.private_key_id) else {
		ErrorText("Error: Cannot find certificate for Private Key ID: \(sig.private_key_id)")
		return -1
	}

	if arg_debug {
		DebugText("")
		DebugText("Found certificate for Private Key ID \(sig.private_key_id)")
		DebugText("****************************************")
		DebugText(cert)
	}

	openssl_init()

	guard let public_key = GetPublicKeyFromX509PemCertificate(cert: cert) else {
		ErrorText("Error: Cannot extract public key from certificate")
		return -1
	}

	if arg_debug {
		print("Public Key:")
		print(public_key)
	}

	var signature: Data?

	//****************************************
	// Convert encoded signature to binary
	//****************************************

	switch sig.format {
	case "base64":
		signature = Data(base64Encoded: sig.signature)
	case "base64url":
		let b64 = base64urlToBase64(base64url: sig.signature)
		signature = Data(base64Encoded: b64)
	case "hex":
		signature = hexToBinary(hex: sig.signature)
	default:
		ErrorText("Error: Invalid signature format. Values are base64, base64url, hex")
		return -1
	}

	//****************************************
	//
	//****************************************

	guard let signature = signature else {
		ErrorText("Error: Cannot convert encoded signature to Data")
		return -1
	}

	//****************************************
	// Verify part
	//****************************************

	// print("Verify")

	let ret = verify_rsa_sha256_pubkey_string(data: input, pubkey: public_key, signature: signature)

	if ret != 0 {
		ErrorText("Error: Verify failed: \(ret)")
		return -1
	}

	return 0
}
