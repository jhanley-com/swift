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

let version = "0.90.0 (2023/02/10)"

func main() -> Int32 {
	if _isatty(STDOUT_FILENO) != 0 {
		setupConsole()
	}

	defer {
		restoreConsole()
	}

	var ret: Int32 = 0

	//****************************************
	// Process environment and command line
	//****************************************

	ret = ProcessEnvironment()

	if ret != 0 {
		return ret
	}

	ret = ProcessCommandLine()

	if ret != 0 {
		return ret
	}

	//****************************************
	//
	//****************************************

	if arg_test {
		return run_tests()
	}

	//****************************************
	//
	//****************************************

	if arg_debug {
		DebugText("Input file: \(input_file ?? "reading stdin")")
	}

	//****************************************
	//
	//****************************************

	return processDigestCommand()
}

func processDigestCommand() -> Int32 {
	//****************************************
	// Read input from stdin or file
	//****************************************

	if let input_file {
		do {
			let fh = FileHandle(forReadingAtPath: input_file)

			guard let fh else {
				ErrorText("Error: Cannot open file")
				return Int32(-1)
			}

			let d = try Digest(using: digest_algorithm)

			while true {
				let data = try fh.read(upToCount: 65536)

				guard let data else {
					break
				}

				let _ = try d.update(data: data)
			}

			let digest = try d.final()

			try fh.close()

			return writeDigest(data: digest)
		}
		catch {
			ErrorText(error.localizedDescription)
			ErrorText("Error: Cannot process input file \(input_file)")
			return 1
		}
	}

	//****************************************
	//
	//****************************************

	InfoText("Reading from stdin")

	do {
		_setmode(_fileno(stdin), O_BINARY)

		let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: 65536)

		let d = try Digest(using: digest_algorithm)

		while true {
			let count = fread(buf, 1, 65536, stdin)

			if count <= 0 {
				break
			}

			let _ = try d.update(ptr: buf, count: UInt32(count))
		}

		let digest = try d.final()

		return writeDigest(data: digest)
	}
	catch {
		ErrorText("\(error)")
		return Int32(-1)
	}
}

func writeDigest(data digest: Data) -> Int32 {
	switch digest_format {
		case "base64":
			return writeString(string: digest.base64EncodedString())
		case "base64url":
			return writeString(string: digest.base64UrlEncodedString())
		case "hex":
			return writeString(string: digest.hexEncodedString())
		case "binary":
			return writeBinary(data: digest)
		default:
			ErrorText("Error: Invalid digest format (\(digest_format)). Supported values are base64, base64url, binary, hex")
			return Int32(-1)
	}
}

func formatDigest(_ value: String) -> String {
	var outstr = value

	if arg_openssl == true {
		let alg = "\(digest_algorithm)".uppercased()
		if let input_file {
			outstr = "\(alg)(\(input_file))= \(value)"
		} else {
			outstr = "\(alg)(stdin)= \(value)"
		}
	}

	if arg_coreutils == true {
		if let input_file {
			outstr = "\(value) *\(input_file)"
		} else {
			outstr = "\(value) *stdin"
		}
	}

	return outstr
}

func writeString(string value: String) -> Int32 {
	let outstr = formatDigest(value)

	guard let output_file else {
		// This is not an error. Write the digest to stdout
		OutputText(outstr)
		return 0
	}

	do {
		if !arg_silent {
			InfoText("Writing digest to \(output_file)")
		}
		try outstr.write(toFile: output_file, atomically: false, encoding: .utf8)

		return Int32(0)
	}
	catch {
		ErrorText(error.localizedDescription)
		ErrorText("Error: Cannot write digest to file")
		return -1
	}
}

func writeBinary(data digest: Data) -> Int32 {
	guard let output_file else {
		if _isatty(STDOUT_FILENO) == 0 {
			let mode = _setmode(_fileno(stdout), O_BINARY)

			digest.withUnsafeBytes { ptr in
				let bytes = ptr.bindMemory(to: UInt8.self).baseAddress!
				let _ = fwrite(bytes, 1, ptr.count, stdout)
			}

			_setmode(_fileno(stdout), mode)

			return 0
		}

		ErrorText("Error: Cannot write binary data to stdout")
		return -1
	}

	do {
		if !arg_silent {
			InfoText("Writing digest to \(output_file)")
		}
		let url = URL(fileURLWithPath: output_file)
		try digest.write(to: url)

		return 0
	}
	catch {
		ErrorText(error.localizedDescription)
		ErrorText("Error: Cannot write digest to file")
		return -1
	}
}

exit(main())

// let _ = test_sha256_12()
