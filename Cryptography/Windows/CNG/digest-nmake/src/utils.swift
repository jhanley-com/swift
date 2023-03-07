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

func removeFile(_ path: String) {
	do {
		if FileManager.default.fileExists(atPath: path) {
			try FileManager.default.removeItem(atPath: path)
		}
	}
	catch {
		ErrorText("Remove file failed: \(error)")
	}
}

func NT_SUCCESS(_ status: Int32) -> Bool {
	if status < 0 {
		return false
	}

	return true
}

func copyWideChars(source: String, destination: UnsafeMutablePointer<UInt16>) {
	var index = 0

	let data = source.data(using: .utf8)!

	for _ in source {
		destination[index] = UInt16(data[index])
		index += 1
	}

	destination[index] = 0
}

func removeTrailingNL(string str: String) -> String {
	var value = str

	while value.last == "\n" || value.last == "\r" || value.last == "\r\n" {
		value = String(str.dropLast())
	}

	return value
}
