/*****************************************************************************
* Date Created: 2022-12-11
* Last Update:  2022-12-11
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

// load certificate from url
func test3() {
	let private_key_id = "e13865c614f69924d0b6dc1a8753d1c5c349b19b"
	let client_x509_cert_url = "https://www.googleapis.com/robot/v1/metadata/x509/889131808239-compute%40developer.gserviceaccount.com"

	// print(private_key_id)
	// print(cert_url)

	guard let cert = GetPublicCertificate(cert_url: client_x509_cert_url, private_key_id: private_key_id) else {
		print("Error: Cannot find certificate for Private Key ID: \(private_key_id)")
		return
	}

	// print()
	// print("Found certificate for Private Key ID \(private_key_id)")
	// print("****************************************")
	// print(cert)

	openssl_init()

	guard let public_key = GetPublicKeyFromX509PemCertificate(cert: cert) else {
		print("Error: Cannot extract public key from certificate")
		return
	}

	print("Public Key:")
	print(public_key)
}

// Extract public key from certificate
func GetPublicKeyFromX509PemCertificate(cert: String) -> String? {

	guard let public_key_ptr = openssl_get_publickey_from_certificate(cert) else {
		return nil
	}

	let public_key = String(cString: public_key_ptr)

	malloc_free(public_key_ptr);

	return public_key
}

func GetPublicCertificate(cert_url: String, private_key_id: String) -> String? {
	// print("URL: \(cert_url)")

	guard let url = URL(string: cert_url) else {
		return nil
	}

	do {
		let contents = try String(contentsOf: url, encoding: .utf8)
// print(contents)

		guard let data = contents.data(using: .utf8) else {
			print("Error: Cannot parse certificate response data")
			return nil
		}

		let decoder = JSONDecoder()

		let certs = try decoder.decode([String: String].self, from: data)

		// print(certs)

		for cert in certs {
			if cert.key.compare(private_key_id) != .orderedSame {
				continue
			}

			return cert.value
		}

		return nil
	}
	catch {
		print(error)
		return nil
	}
}
