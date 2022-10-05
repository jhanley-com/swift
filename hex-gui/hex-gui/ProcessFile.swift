/*****************************************************************************
* Date Created: 2022-10-04
* Last Update:  2022-10-04
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

/*
This function can consume all memory on very large files
func processFile(_ url: URL?) -> String {
	guard let url = url else { return "" }

	let file_offset: Int64 = 0
	let maxBytes: Int64 = 0x40000	// 256 KB

	do {
		let data = try Data(contentsOf: url)
		return display_hex(data, file_offset, maxBytes)
	} catch {
		return ""
	}
}
*/

func processFile(_ url: URL?) -> String {
	guard let url = url else { return "" }

	let file_offset: Int64 = 0
	// This limit is hardcoded to prvent consuming all memory.
	// Increase if desired
	let maxBytes: Int64 = 0x40000	// 256 KB

	do {
		let fileHandle = try FileHandle(forReadingFrom: url)

		defer { fileHandle.closeFile() }

		let data = fileHandle.readData(ofLength: Int(maxBytes))

		return display_hex(data, file_offset, maxBytes)
	} catch {
		return ""
	}
}

func display_hex(_ ptr: Data, _ offset: Int64, _ maxbytes: Int64) -> String {
	// This is the formatted hex strings to return to the caller for display
	var text = ""

	var count = 0
	var off: Int64 = 0

	var save = ""

	var tmp: Int64 = 0

	for (_, byte) in ptr.enumerated() {
		if off >= maxbytes {
			break
		}

		// FIX - there must be a better way
		if tmp < offset {
			tmp += 1
			continue
		}

		// This is for the left side display
		let val = String(format: "%02X ", byte)

		// This is for the right side display
		if byte >= 0x20 && byte < 0x7f {
			// This is valid Ascii
			save.append(Character(UnicodeScalar(byte)))
		} else {
			// Use a period character for unpritable data
			save += "."
		}

		// If count is zero, display the current offset
		if count == 0 {
			text += String(format: "%08X ", offset + off)
		}

		// Add a space character after 8 characters to make the hex easier to read
		if count == 8 {
			text += " "
		}

		text += val

		count += 1
		off += 1

		// If 16 bytes have been displayed:
		//   Display the save characters on the right side.
		//   Start a new line
		if count == 16 {
			text += "   \(save)\n"
			save = ""
			count = 0
		}
	}

	if save.count > 0 {
		for x in count...15 {
			if x == 8 {
				text += " "
			}

			text += "   "
		}

		text += "   \(save)\n"
	}

	text += "\n"

	return text
}
