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

struct ServiceAccountJsonKey: Codable {
	var type: String
	var project_id: String
	var private_key_id: String
	var private_key: String
	var client_email: String
	var client_id: String
	var auth_uri: String
	var token_uri: String
	var auth_provider_x509_cert_url: String
	var client_x509_cert_url: String
}

func getServiceAccountJson(filename: String) -> ServiceAccountJsonKey? {
	do {
		if !FileManager.default.fileExists(atPath: filename) {
			ErrorText("Error: file does not exist: \(filename)")
			return nil
		}

		let contents = try String(contentsOfFile: filename, encoding: .utf8)

		guard let data = contents.data(using: .utf8) else {
			ErrorText("Error: Cannot convert service account JSON key file to data: \(filename)")
			return nil
		}

		let decoder = JSONDecoder()

		return try decoder.decode(ServiceAccountJsonKey.self, from: data)
	}
	catch {
		ErrorText(error.localizedDescription)
		ErrorText("Error: Cannot decode service account JSON key")
		return nil
	}
}
