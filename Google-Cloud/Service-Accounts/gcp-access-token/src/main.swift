/*****************************************************************************
* Date Created: 2022-12-14
* Last Update:  2022-12-14
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

let version = "0.90.0 (2022/12/13)"

// In debug mode, print additional information
var arg_debug = false

// Set the environment variable GOOGLE_APPLICATION_CREDENTIALS=path-to-service-account
let gcp_envVarName = "GOOGLE_APPLICATION_CREDENTIALS"
var gcp_sa_file: String? = nil

// OAuth Scopes
// If defining scopes here, use a space between each scope. On the command line use a comma.
var gcp_scopes = "https://www.googleapis.com/auth/cloud-platform"

// Token lifetime in seconds. Default is 3,600 seconds.
var arg_duration: Int = 3600

// Token output filename. If not specified, stdout is written
var output_file: String? = nil

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
	BlueText("gcp-sign [OPTIONS]")
	BlueText("OPTIONS:")
	BlueText("    -h, --help       Display help text")
	BlueText("    -v, --version    Display version information")
	BlueText("    --debug          Enable Debug Mode")
	BlueText("    --duration=sec   Token lifetime in seconds.")
	BlueText("    --out=filename   Filename to save token. If not specified, write to stdout")
	BlueText("    --sa=path        Path to service account JSON key file")
	BlueText("    --scopes=scopes  Scopes to request (comma separated). Defaults to cloud-platform")
}

func ProcessEnvironment() {
	// Process GOOGLE_APPLICATION_CREDENTIAL

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

		if arg.starts(with: "--duration=") {
			let start = arg.index(arg.startIndex, offsetBy: 11)
			let range = start...
			let value = String(arg[range])
			if let n = Int(value) {
				arg_duration = n
				continue
			} else {
				ErrorText("Error: --duration flag must be a number")
				ErrorText(arg)
				exit(1)
			}
		}

		if arg.starts(with: "--out=") {
			let start = arg.index(arg.startIndex, offsetBy: 6)
			let range = start...
			output_file = String(arg[range])
			continue
		}

		if arg.starts(with: "--sa=") {
			let start = arg.index(arg.startIndex, offsetBy: 5)
			let range = start...
			gcp_sa_file = String(arg[range])
			continue
		}

		if arg.starts(with: "--scopes=") {
			let start = arg.index(arg.startIndex, offsetBy: 9)
			let range = start...
			let scopes = String(arg[range])
			gcp_scopes = scopes.components(separatedBy: [" ", ","]).joined(separator: " ")
print("Scopes: \(gcp_scopes)")
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
		DebugText("Service Account JSON Key File: \(gcp_sa_file ?? "not specified")")
		DebugText("Scopes: \(gcp_scopes)")
	}

	//****************************************
	// Google Cloud Service Account JSON file
	//****************************************

	guard let gcp_sa_file else {
		ErrorText("Error: Missing flag or environment setting for service account file")
		exit(1)
	}

	//****************************************
	// Create Signed JWT
	//****************************************

	let issued = Int(Date().timeIntervalSince1970)

	guard let signed_jwt = create_signed_jwt(service_account_file: gcp_sa_file, scopes: gcp_scopes, issued: issued, duration: arg_duration) else {
		exit(1)
	}

	if arg_debug {
		print("")
		print("SIGNED JWT")
		print(signed_jwt)
	}

	//****************************************
	// Exchange Signed JWT for tokens
	//****************************************

	guard var token = exchangeJwtForAccessToken(signed_jwt) else {
		exit(1)
	}

	token.issued = issued;

	if arg_debug {
		print("")
		print("TOKEN:")
		print(token)
	}

	//****************************************
	// Write token as JSON to file
	//****************************************

	do {
		let encoder = JSONEncoder()

		encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

		let d = try encoder.encode(token)

		guard let outdata = String(data: d, encoding: .utf8) else {
			ErrorText("Error: Cannot convert data to string")
			exit(1)
		}

		guard let output_file else {
			// This is not an error. Write the AuthToken to stdout
			print(outdata)
			exit(0)
		}

		// Write to file

		do {
			print("Writing signature to \(output_file)")
			try outdata.write(toFile: output_file, atomically: false, encoding: .utf8)
		}
		catch {
			print(outdata)
			ErrorText(error.localizedDescription)
			ErrorText("Error: Cannot write AuthToken to file")
			exit(1)
		}
	}
	catch {
		ErrorText(error.localizedDescription)
		exit(1)
	}
}

main()
