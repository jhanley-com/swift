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

func print_hex(_ ptr: Data, _ offset: Int64, _ maxbytes: Int64) {
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
			print(String(format: "%08X ", offset + off), terminator: "")
		}

		// Add a space character after 8 characters to make the hex easier to read
		if count == 8 {
			print(" ", terminator: "")
		}

		print(val,  terminator: "")

		count += 1
		off += 1

		// If 16 bytes have been displayed:
		//   Display the save characters on the right side.
		//   Start a new line
		if count == 16 {
			print("   \(save)")
			save = ""
			count = 0
		}
	}

	if save.count > 0 {
		for x in count...15 {
			if x == 8 {
				print(" ", terminator: "")
			}

			print("   ", terminator: "")
		}

		print("   \(save)")
	}

	// print()
}
