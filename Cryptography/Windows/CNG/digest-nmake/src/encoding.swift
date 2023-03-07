/*****************************************************************************
* Date Created: 2022-12-23
* Last Update:  2023-02-10
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

extension Data {
	public func base64UrlEncodedString() -> String {
		let base64 = self.base64EncodedString()
		return base64
			.replacingOccurrences(of: "+", with: "-")
			.replacingOccurrences(of: "/", with: "_")
			.replacingOccurrences(of: "=", with: "")
	}

	public func hexEncodedString() -> String {
		return self.map { String(format: "%02hhx", $0) }.joined()
	}
}

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
