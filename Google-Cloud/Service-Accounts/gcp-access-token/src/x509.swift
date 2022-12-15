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

	var contents = ""

	do {
		contents = try String(contentsOf: url, encoding: .utf8)
	}
	catch {
		print(error)
		ErrorText("Error: Cannot read certificate from URL")
		ErrorText("Error: URL: \(url)")
		return nil
	}

	// print(contents)

	guard let data = contents.data(using: .utf8) else {
		ErrorText("Error: Cannot parse certificate response data")
		return nil
	}

	do {
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
		ErrorText(error.localizedDescription)
		return nil
	}
}
