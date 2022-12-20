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

//****************************************
// Signature file format
//
// {
//   "private_key_id": "same as service account JSON key file",
//   "client_x509_cert_url": "same as service account JSON key file",
//   "format": "base64",
//   "signature": "encoded binary string"
// }
//****************************************

struct SignatureFile: Codable {
	var private_key_id: String
	var client_x509_cert_url: String
	var format: String
	var signature: String
}

func readSignatureFile(filename: String) -> SignatureFile? {
	do {
		if !FileManager.default.fileExists(atPath: filename) {
			ErrorText("Error: file does not exist: \(filename)")
			return nil
		}

		let contents = try String(contentsOfFile: filename, encoding: .utf8)

		guard let data = contents.data(using: .utf8) else {
			ErrorText("Error: Cannot convert signature file: \(filename)")
			return nil
		}

		let decoder = JSONDecoder()

		return try decoder.decode(SignatureFile.self, from: data)
	}
	catch {
		ErrorText(error.localizedDescription)
		ErrorText("Error: Cannot decode signature file JSON")
		return nil
	}
}

// I am not sure when base64url is required
// JWT uses base64url encoding, not base64 encoding
// Swift Data(base64Encoded: base64) requires base64 encoding, fails with base64url encoding
//
// different characters are used for index 62 and 63 (- and _ instead of + and /)
// no mandatory padding with = characters to make the string length a multiple of four.
//
// This function converts base64 to base64url encoding

func base64ToBase64url(base64: String) -> String {
	let base64url = base64
		.replacingOccurrences(of: "+", with: "-")
		.replacingOccurrences(of: "/", with: "_")
		.replacingOccurrences(of: "=", with: "")

	return base64url
}

// This function converts base64url to base64 encoding

func base64urlToBase64(base64url: String) -> String {
	var base64 = base64url
		.replacingOccurrences(of: "-", with: "+")
		.replacingOccurrences(of: "_", with: "/")

	if base64.count % 4 != 0 {
		base64.append(String(repeating: "=", count: 4 - base64.count % 4))
	}

	return base64
}

func binaryToHex(data: Data) -> String {
	return data.map { String(format: "%02hhX", $0) }.joined()
}

func hexToBinary(hex: String) -> Data {
	let chars = Array(hex)

	var bytes = [UInt8]()
	bytes.reserveCapacity(chars.count / 2)

	for i in stride(from: 0, to: chars.count, by: 2) {
		let c1 = UInt8(String(chars[i]), radix: 16) ?? 0
		let c2 = UInt8(String(chars[i + 1]), radix: 16) ?? 0

		bytes.append(c1 << 4 | c2)
	}

	return Data(bytes)
}
