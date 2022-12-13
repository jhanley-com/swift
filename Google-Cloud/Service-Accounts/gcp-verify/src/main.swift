/*****************************************************************************
* Date Created: 2022-12-12
* Last Update:  2022-12-12
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

let version = "0.90.0 (2022/12/12)"

// In debug mode, print additional information
var arg_debug = false

// Data to be signed. If not specified, stdin is read
var input_file: String? = nil

// Signature input filename. If not specified, stdout is written
var signature_file: String? = nil

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
	BlueText("    --signture=path  Signature file")
}

func ProcessEnvironment() {
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
}

func ProcessCommandLine() {
	for arg in CommandLine.arguments[1...] {
		if arg == "-h" || arg == "--help" {
			Usage()
			exit(0)
		}

		if arg == "-v" || arg == "-V" || arg == "--version" {
			Version()
			exit(0)
		}

		if arg == "--debug" {
			arg_debug = true
			continue
		}

		if arg.starts(with: "--signature=") {
			signature_file = arg.substring(from: 12)
			continue
		}

		if arg.starts(with: "--") {
			ErrorText("Error: Unexpected command flag: \(arg)")
			exit(1)
		}

		if arg.starts(with: "-") {
			ErrorText("Error: Unexpected command flag: \(arg)")
			exit(1)
		}

		if input_file == nil {
			input_file = arg
			continue
		}

		ErrorText("Error: Unexpected command parameter: \(arg)")
		exit(1)
	}
}

func main() {
	//****************************************
	// Process environment and command line
	//****************************************

	ProcessEnvironment()

	ProcessCommandLine()

	if arg_debug {
		DebugText("Signature file: \(signature_file ?? "not specified")")
		DebugText("Input file: \(input_file ?? "reading stdin")")
	}

	//****************************************
	// Signature File
	//****************************************

	guard let signature_file = signature_file else {
		ErrorText("Error: Missing signature file")
		exit(1)
	}

	//****************************************
	// Read input from stdin or file
	//****************************************

	var input = Data()

	if let input_file = input_file {
		do {
			input = try Data(contentsOf: URL(fileURLWithPath: input_file))
		}
		catch {
			ErrorText(error.localizedDescription)
			ErrorText("Error: Cannot read input file \(input_file)")
			exit(1)
		}
	} else {
		input = readStdinInBinaryMode()
	}

	//****************************************
	// Verify
	//****************************************

	let ret = verify(signature_filename: signature_file, input: input)

	if ret != 0 {
		ErrorText("Error: Verify failed")
		exit(Int32(ret))
	}

	print("Verify success")

	exit(0)
}

main()
