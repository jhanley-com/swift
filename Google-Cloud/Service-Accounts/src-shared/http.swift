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
#if !os(macOS)
import FoundationNetworking	// This is required for Linux, does not exist on macOS
#endif

func http_post(uri: String, headers: Dictionary<String, String>, body: String) -> String? {
	
	if arg_debug {
		DebugText("URI: \(uri)")
	}

	guard let url = URL(string: uri) else {
		ErrorText("Error: Cannot create URL")
		return nil
	}

	guard let data = body.data(using: .utf8) else {
		fatalError("Error: Cannot encode HTTP POST body data")
	}

	var request = URLRequest(url: url)

	request.httpMethod = "POST"
	request.httpBody = data

	for (key, value) in headers {
		request.setValue(value, forHTTPHeaderField: key)
	}

	let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)

	var response_string: String? = nil
	var statusCode: Int = 0

	let task = URLSession.shared.dataTask(with:request) { (data, response, error) in
		if arg_debug {
			DebugText("------------------------------------------------------------")
			DebugText("DATA:")
			DebugText("")

			if let data = data {
				if let dataString = String(data: data, encoding: .utf8) {
					DebugText(dataString)
				}
			}

			DebugText("------------------------------------------------------------")

			// DebugText("response: \(response!)")
			// DebugText("error: \(error!)")
		}

		if let error = error as! URLError? {
			ErrorText("------------------------------------------------------------")
			ErrorText("Error: \(error.localizedDescription)")
			ErrorText("------------------------------------------------------------")
			semaphore.signal()
			return
		}

		if let httpResponse = response as? HTTPURLResponse {
			if arg_debug {
				DebugText("httpResponse:")
				DebugText("")

				DebugText("\(httpResponse)")
			}

			statusCode = httpResponse.statusCode

			if statusCode < 200 || statusCode >= 300 {
				ErrorText("")
				ErrorText("------------------------------------------------------------")
				ErrorText("HTTP GET REQUEST ERROR:")
				ErrorText("statusCode: \(statusCode)")

				/*
				if let r = response {
					if let response_url = r.url {
						BlueText("Response URL: \(response_url)")
					}
					if let response_mime_type = r.mimeType {
						BlueText("Response Mime Type: \(response_mime_type)")
					}
				}
				*/

				if let data = data {
					if let dataString = String(data: data, encoding: .utf8) {
						ErrorText(dataString)
					}
				}

				ErrorText("------------------------------------------------------------")

				semaphore.signal()
				return
			}
		}

		if let data = data {
			if let dataString = String(data: data, encoding: .utf8) {
				response_string = dataString
			} else {
				ErrorText("Error: No Response")
			}
			semaphore.signal()
			return
		}

		semaphore.signal()
		return
	}
	task.resume()

	semaphore.wait()

/*
	if statusCode < 200 || statusCode >= 300 {
		ErrorText("statusCode: \(statusCode)")
		return nil
	}
*/

	return response_string
}
