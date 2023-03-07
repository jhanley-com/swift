/*****************************************************************************
* Date Created: 2022-11-22
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

func DebugText(_ msg: String) {
	fputs(msg, stderr)
	fputs("\n", stderr)
	fflush(stderr)
}

func BlueText(_ msg: String) {
	if nocolor == false {
		print("\u{001B}[01;34m" + msg + "\u{001B}[0m")
	} else {
		print(msg)
	}
	fflush(stdout)
}

func InfoText(_ msg: String) {
	fputs(msg, stderr)
	fputs("\n", stderr)
	fflush(stderr)
}

func OutputText(_ msg: String, terminator term: String = "\n") {
	fputs(msg, stdout)
	if term != "" {
		fputs(term, stdout)
	}
	fflush(stdout)
}

func ErrorText(_ msg: String) {
	fflush(stdout)

	if nocolor == false {
		fputs("\u{001B}[01;31m" + msg + "\u{001B}[0m\n", stderr)
	} else {
		fputs(msg, stderr)
	}

	fflush(stderr)
}

func getTerminalWindowSize() -> (Int, Int, Int) {
#if os(Windows)
	if _isatty(STDOUT_FILENO) == 0 {
		return (0, 128, 100)
	}
#else
	if isatty(STDOUT_FILENO) == 0 {
		return (0, 128, 100)
	}
#endif

	var cols: Int32 = 0
	var rows: Int32 = 0

	getConsoleWindowsSize(&cols, &rows)

	return (0, Int(cols), Int(rows))
}

#if os(Windows)
func readStdinInBinaryMode() -> Data {
	// This function is for Microsoft Windows

	var data = Data()

	_setmode(_fileno(stdin), O_BINARY)

	while true {
		let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: 65536)

		let count = fread(buf, 1, 65536, stdin)

		if count <= 0 {
			break
		}
		data.append(Data(bytes: buf, count: count))
	}

	return data
}
#elseif os(Linux)
func readStdinInBinaryMode() -> Data {
	// This function tested on Ubuntu 22.04

	var data = Data()

	freopen(nil, "rb", stdin)

	while true {
		let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: 65536)

		let count = fread(buf, 1, 65536, stdin)

		if count <= 0 {
			break
		}
		data.append(Data(bytes: buf, count: count))
	}

	return data
}
#elseif os(macOS)
func readStdinInBinaryMode() -> Data {
	// This function tested on macOS Monterey

	var data = Data()

	freopen(nil, "rb", stdin)

	while true {
		let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: 65536)

		let count = fread(buf, 1, 65536, stdin)

		if count <= 0 {
			break
		}
		data.append(Data(bytes: buf, count: count))
	}

	return data
}
#endif
