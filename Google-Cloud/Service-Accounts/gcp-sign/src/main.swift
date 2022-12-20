/*****************************************************************************
* Date Created: 2022-12-12
* Last Update:  2022-12-19
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

let version = "0.91.0 (2022/12/19)"

// In debug mode, print additional information
var arg_debug = false

// Data to be signed. If not specified, stdin is read
var input_file: String? = nil

// Signature output filename. If not specified, stdout is written
var output_file: String? = nil

// Signature format.  base64 (default), base64url, hex
var signature_format = "base64"

// Set the environment variable GOOGLE_APPLICATION_CREDENTIALS=path-to-service-account
let gcp_envVarName = "GOOGLE_APPLICATION_CREDENTIALS"
var gcp_sa_file: String? = nil

// This controls if coloring is disabled.
// This value is read from the environment:
// Windows: set MSG_NOCOLOR=true
// Linux: export MSG_NOCOLOR=true
let msg_nocolor_envVarName = "MSG_NOCOLOR"
var nocolor = false

func Version() {
	print("Version: \(version)")
}

func Usage() {
	BlueText("gcp-sign [OPTIONS] filename")
	BlueText("OPTIONS:")
	BlueText("    -h, --help       Display help text")
	BlueText("    -v, --version    Display version information")
	BlueText("    --debug          Enable Debug Mode")
	BlueText("    --sa=path        Path to service account JSON key file")
	BlueText("    --signature=path Signature file. If not specified, write to stdout")
	BlueText("    --format=format  Signature format. base64 (default), base64url, hex")
}

func ProcessEnvironment() -> Int32 {
	// Process GOOGLE_APPLICATION_CREDENTIALS

	var key = gcp_envVarName

	if let value = ProcessInfo.processInfo.environment[key] {
		gcp_sa_file = value
	}

	// Process error message color setting
	key = msg_nocolor_envVarName

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

		if arg.starts(with: "--sa=") {
			let start = arg.index(arg.startIndex, offsetBy: 5)
			let range = start...
			gcp_sa_file = String(arg[range])
			continue
		}

		if arg.starts(with: "--signature=") {
			let start = arg.index(arg.startIndex, offsetBy: 12)
			let range = start...
			output_file = String(arg[range])
			continue
		}

		if arg.starts(with: "--format=") {
			let start = arg.index(arg.startIndex, offsetBy: 9)
			let range = start...
			let format = String(arg[range])

			switch format {
			case "base64":
				signature_format = format
			case "base64url":
				signature_format = format
			case "hex":
				signature_format = format
			default:
				ErrorText("Error: Invalid signature format. Values are base64, base64url, hex")
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

	return 0
}

func main() -> Int32 {
#if os(Windows)
	setupConsole()
	defer {
		restoreConsole()
	}
#endif

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

	if arg_debug {
		DebugText("Service Account JSON Key File: \(gcp_sa_file ?? "not specified")")
		DebugText("Input file: \(input_file ?? "reading stdin")")
	}

	//****************************************
	// Google Cloud Service Account JSON file
	//****************************************

	guard let gcp_sa_file else {
		ErrorText("Error: Missing command line flag or environment variable GOOGLE_APPLICATION_CREDENTIALS for service account file")
		return 1
	}

	//****************************************
	// Read input from stdin or file
	//****************************************

	var input = Data()

	if let input_file {
		do {
			input = try Data(contentsOf: URL(fileURLWithPath: input_file))
		}
		catch {
			ErrorText(error.localizedDescription)
			ErrorText("Error: Cannot read input file \(input_file)")
			return 1
		}
	} else {
		input = readStdinInBinaryMode()
	}

	//****************************************
	// Sign
	//****************************************

	ret = Int32(sign(service_account_file: gcp_sa_file, input: input, output: output_file, format: signature_format))

	return ret
}

exit(main())
