/*****************************************************************************
* Date Created: 2022-11-29
* Last Update:  2022-11-29
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

struct GitHubDeviceCodeResponse: Codable {
	var device_code: String
	var user_code: String
	var verification_uri: String
	var expires_in: Int
	var interval: Int
}

struct GitHubDeviceCodeTokenResponse: Codable {
	var access_token: String
	var scope: String
	var token_type: String
}

struct GitHubAuthError: Codable {
	var error: String
	var error_description: String
	var error_uri: String
}

func GetAccessToken(code: GitHubDeviceCodeResponse, msg: String) -> String? {
	let base_uri = "https://github.com/login/oauth/access_token"
	let uri = "\(base_uri)?client_id=\(arg_client_id)&device_code=\(code.device_code)&grant_type=urn:ietf:params:oauth:grant-type:device_code"

	let headers: Dictionary<String, String> = ["Accept": "application/json"]

	let decoder = JSONDecoder()

	var first_msg = false
	var msg_count = 0

	var sleep_interval = 5.0

	while true {
		if msg_count >= 56 {
			msg_count = 0
			first_msg = false
			print()
		}

		if msg_count == 0 {
			print(msg)
		}

		if first_msg == false {
			first_msg = true
			print("Waiting for authorization .", terminator: "")
		} else {
			print(".", terminator: "")
		}
#if os(macOS)
		fflush(stdout)
#endif

		msg_count += 1

		Thread.sleep(forTimeInterval: sleep_interval)

		guard let response_string = http_post(uri: uri, headers: headers) else {
			print()
			ErrorText("Error: Request Failed")
			continue
		}

		guard let response = response_string.data(using: .utf8) else {
			print()
			ErrorText("Error: Cannot convert response string to data")
			return nil
		}

		do {
			if arg_debug {
				DebugText(response_string)
			}

			// One of two json responses were returned:
			// GitHubDeviceCodeTokenResponse
			// GitHubAuthError

			if response_string.contains("error_description") {
				let authError = try decoder.decode(GitHubAuthError.self, from: response)

				if authError.error.compare("slow_down") == .orderedSame {
					print("\u{8}+", terminator: "")
					sleep_interval += 5

					if sleep_interval >= 30 {
						print()
						ErrorText("Authorization Failed")
						ErrorText("Error: \(authError.error)")
						ErrorText("Desc:  \(authError.error_description)")
						ErrorText("GitHub has rate limited this application. Wait and try again later.")
						return nil
					}

					continue
				}

				if authError.error.compare("authorization_pending") == .orderedSame {
					continue
				}

				print()
				print("")
				ErrorText("Authorization Failed")
				ErrorText("Error: \(authError.error)")
				ErrorText("Desc:  \(authError.error_description)")
				ErrorText("URI:   \(authError.error_uri)")
			} else {
				let token = try decoder.decode(GitHubDeviceCodeTokenResponse.self, from: response)

				print()
				DebugText("")
				DebugText("Authorization Succeeded")
				DebugText("Scope: \(token.scope)")
				DebugText("Type:  \(token.token_type)")
				DebugText("Token: \(token.access_token)")

				return token.access_token
			}

			return nil
		} catch {
			print()
			print("")
			ErrorText("Authorization Failed")
			ErrorText(error.localizedDescription)
			ErrorText(response_string)

			break
		}
	}

	return nil
}

func Authorize() -> String? {
	let base_uri = "https://github.com/login/device/code"

	let uri = "\(base_uri)?client_id=\(arg_client_id)&scope=\(arg_scope)"

	let headers: Dictionary<String, String> = ["Accept": "application/json"]

	print("Requesting Device Authorization Grant")

	guard let response_string = http_post(uri: uri, headers: headers) else {
		ErrorText("Error: Request Failed")
		return nil
	}

	guard let response = response_string.data(using: .utf8) else {
		ErrorText("Error: Cannot convert response string to data")
		return nil
	}

	do {
		let decoder = JSONDecoder()

		let code = try decoder.decode(GitHubDeviceCodeResponse.self, from: response)

		// DebugText(code)
		// DebugText("URI:  \(code.verification_uri)")
		// DebugText("Code: \(code.user_code)")

		let msg = "Start a webbrowser at \(code.verification_uri) and enter the code \(code.user_code)"

		return GetAccessToken(code: code, msg: msg)
	} catch {
		ErrorText(String(data: response, encoding: .utf8)!)
		ErrorText(error.localizedDescription)
		return nil
	}
}
