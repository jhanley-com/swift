/*****************************************************************************
* Date Created: 2022-09-29
* Last Update:  2022-09-29
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

let version = "0.90.0 (2022/09/29)"

// This controls if coloring is disabled.
// This value is read from the environment:
// Windows: set HEX_NOCOLOR=true
// Linux: export HEX_NOCOLOR=true
var nocolor = false

// Filename to read
var filename: String = ""

// Size of filename
var filesize: Int64 = 0

// Maximum number of bytes to display, defaults to size of file
var maxBytes: Int64 = -1

// Offset in file to display
var file_offset: Int64 = 0

func Version() {
	print("Version: \(version)")
}

func Usage() {
	BlueText("hex [OPTIONS] filename offset count")
	BlueText("OPTIONS:")
	BlueText("    -h, --help       Display help text")
	BlueText("    -v, --version    Display version information")
}

func BlueText(_ msg: String) {
	if nocolor == false {
		print("\u{001B}[01;34m" + msg + "\u{001B}[0m")
	} else {
		print(msg)
	}
}

func ErrorText(_ msg: String) {
	if nocolor == false {
		print("\u{001B}[01;31m" + msg + "\u{001B}[0m")
	} else {
		print(msg)
	}
}

func ProcessEnvironment() {
	let key = "HEX_NOCOLOR"

	if let value = ProcessInfo.processInfo.environment[key] {
		if value == "true" || value == "1" {
			nocolor = true
		} else if value == "false" || value == "0" {
			nocolor = false
		} else {
			ErrorText("Error: Unexpected HEX_NOCOLOR value: \(value)")
		}
	}
}

func ProcessCommandLine() {
	if CommandLine.arguments.count < 2 {
		Usage()
		ErrorText("Error: missing filename")
		exit(1)
	}

	var max_set = false
	var off_set = false

	for arg in CommandLine.arguments[1...] {
		if arg == "-h" || arg == "--help" {
			Usage()
			exit(0)
		}

		if arg == "-v" || arg == "-V" || arg == "--version" {
			Version()
			exit(0)
		}

		if filename == "" {
			filename = arg
			continue
		}
		if off_set == false {
			off_set = true
			if arg.starts(with: "0x") {
				let ss = arg.dropFirst(2)
				file_offset = Int64(ss, radix: 16) ?? 0
			} else {
				file_offset = Int64(arg) ?? 0
			}
			continue
		}

		if max_set == false {
			max_set = true
			if arg.starts(with: "0x") {
				let ss = arg.dropFirst(2)
				maxBytes = Int64(ss, radix: 16) ?? 0
			} else {
				maxBytes = Int64(arg) ?? -1
			}
			continue
		}

		ErrorText("Error: Unexpected command parameter: \(arg)")
		exit(1)
	}
}

func GetFileSize(_ filename: String) -> Int64 {
	if let fileAttributes = try? FileManager.default.attributesOfItem(atPath: filename) {
		if let bytes = fileAttributes[.size] as? Int64 {
			return bytes
		}
	}

	ErrorText("Error: problem determing file size")
	exit(1)
}

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

	print()
}

func main() {
	ProcessEnvironment()

	ProcessCommandLine()

	filesize = GetFileSize(filename)

	if file_offset < 0 {
		file_offset = 0
	}

	if file_offset >= filesize {
		ErrorText("Error: File offset past end of file")
		exit(1)
	}

	if maxBytes < 0 {
		maxBytes = filesize
	}

	if maxBytes > filesize - file_offset {
		maxBytes = filesize - file_offset
	}

	do {
		let url = URL(fileURLWithPath: filename)
		let data = try Data(contentsOf: url)

		print_hex(data, file_offset, maxBytes)
	} catch {
		ErrorText("Error: \(error)")
	}
}

main()
