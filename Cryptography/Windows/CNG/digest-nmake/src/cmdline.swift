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

// In debug mode, print additional information
var arg_debug = false

// Flag used to silence some messages during tests
var arg_silent = false

// In test mode, run tests only
var arg_test = false

// Print the digest in OpenSSL format
var arg_openssl = false

// Print the digest in coreutils format
var arg_coreutils = false

// Data to be signed. If not specified, stdin is read
var input_file: String? = nil

// Digest output filename. If not specified, stdout is written
var output_file: String? = nil

// Digest algorithm. md5, sha1, sha256, sha384 and sha512 are supported.
// The command line only supports sha256.
// This value is changed bu the test functions
var digest_algorithm = Digest.Algorithm.sha256

// Digest format.  base64, base64url, binary, hex (default)
var digest_format = "hex"

// This controls if coloring is disabled.
// This value is read from the environment:
// Windows: set MSG_NOCOLOR=true
// Linux: export MSG_NOCOLOR=true
let msg_nocolor_envVarName = "MSG_NOCOLOR"
var nocolor = false

func Version() {
	InfoText("Version: \(version)")
}

func Usage() {
	BlueText("digest [OPTIONS] [FILENAME]")
	BlueText("OPTIONS:")
	BlueText("    -h, --help       Display help text")
	BlueText("    -v, --version    Display version information")
	BlueText("    --debug          Enable Debug Mode")
	BlueText("    --md5            Create an MD5 digest")
	BlueText("    --sha1           Create a SHA1 digest")
	BlueText("    --sha256         Create a SHA256 digest")
	BlueText("    --sha384         Create a SHA384 digest")
	BlueText("    --sha512         Create a SHA512 digest")
	BlueText("    --openssl        Print the digest in OpenSSL format")
	BlueText("    --coreutils      Print the digest in coreutils format")
	BlueText("    --format=format  Digest format. base64, base64url, binary, hex (default)")
	BlueText("    --out=filename   Name of file to write. If not specified, write to stdout")
	BlueText("    FILENAME         Name of file to read. If not specified, read from stdin ")
}

func ProcessEnvironment() -> Int32 {
	// Process error message color setting
	let key = msg_nocolor_envVarName

	if let value = ProcessInfo.processInfo.environment[key] {
		if value == "true" || value == "1" {
			nocolor = true
		} else if value == "false" || value == "0" {
			nocolor = false
		} else {
			ErrorText("Error: Unexpected \(key) value: \(value)")
		}
	}

	return 0
}

func ProcessCommandLine() -> Int32 {
	var flag = false

	for arg in CommandLine.arguments[1...] {
		if arg == "-h" || arg == "--help" {
			Usage()
			return 1
		}

		if arg == "-v" || arg == "-V" || arg == "--version" {
			Version()
			return 1
		}

		if arg == "--debug" {
			arg_debug = true
			continue
		}

		if arg == "--test" {
			arg_test = true
			continue
		}

		if arg == "--md5" {
			flag = true
			digest_algorithm = Digest.Algorithm.md5
			continue
		}

		if arg == "--sha1" {
			flag = true
			digest_algorithm = Digest.Algorithm.sha1
			continue
		}

		if arg == "--sha256" {
			flag = true
			digest_algorithm = Digest.Algorithm.sha256
			continue
		}

		if arg == "--sha384" {
			flag = true
			digest_algorithm = Digest.Algorithm.sha384
			continue
		}

		if arg == "--sha512" {
			flag = true
			digest_algorithm = Digest.Algorithm.sha512
			continue
		}

		if arg == "--openssl" {
			arg_openssl = true
			arg_coreutils = false
			continue
		}

		if arg == "--coreutils" {
			arg_coreutils = true
			arg_openssl = false
			continue
		}

		if arg.starts(with: "--out=") {
			let start = arg.index(arg.startIndex, offsetBy: 6)
			let range = start...
			output_file = String(arg[range])

			if output_file?.count == 0 {
				ErrorText("Error: Missing value for flag: --out=")
				return 1
			}

			continue
		}

		if arg.starts(with: "--format=") {
			let start = arg.index(arg.startIndex, offsetBy: 9)
			let range = start...
			let format = String(arg[range])

			switch format {
			case "base64":
				digest_format = format
			case "base64url":
				digest_format = format
			case "binary":
				digest_format = format
			case "hex":
				digest_format = format
			default:
				ErrorText("Error: Invalid digest format (\(format)). Values are base64, base64url, binary, hex")
				exit(1)
			}
			continue
		}

		if arg.starts(with: "--") {
			ErrorText("Error: Unexpected command flag: \(arg)")
			return 1
		}

		if arg.starts(with: "-") {
			ErrorText("Error: Unexpected command flag: \(arg)")
			return 1
		}

		if input_file == nil {
			input_file = arg
			continue
		}

		ErrorText("Error: Unexpected command parameter: \(arg)")
		return 1
	}

	if flag == false && arg_test == false {
		ErrorText("Error: missing digest algorithm")
		Usage()
		return 1
	}

	return 0
}
