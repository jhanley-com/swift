/*****************************************************************************
* Date Created: 2022-11-29
* Last Update:  2022-11-29
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

let version = "0.90.0 (2022/11/29)"

var arg_client_id = ""
var arg_scope = "user:email"

// In debug mode, print additional information
var arg_debug = false

// Set the environment variable GITHUB_CLIENT_ID=client_id
let github_client_id_name = "GITHUB_CLIENT_ID"

// Set the environment variable GITHUB_SCOPE=scopes
let github_scope_name = "GITHUB_SCOPE"

// This controls if coloring is disabled.
// This value is read from the environment:
// Windows: set MSG_NOCOLOR=true
// Linux: export MSG_NOCOLOR=true
var nocolor = false

func Version() {
	print("Version: \(version)")
}

func Usage() {
	BlueText("auth-device [OPTIONS]")
	BlueText("OPTIONS:")
	BlueText("    -h, --help       Display help text")
	BlueText("    -v, --version    Display version information")
	BlueText("    --debug          Enable Debug Mode")
	// BlueText("    --client_id=id   GitHub OAuth Client ID")
	// BlueText("    --scope=scope    GitHub scopes")
}

func ProcessEnvironment() {
	// Process GitHub Client ID

	var key = github_client_id_name

	if let value = ProcessInfo.processInfo.environment[key] {
		arg_client_id = value
	}
	// Process GitHub OAuth Scope

	key = github_scope_name

	if let value = ProcessInfo.processInfo.environment[key] {
		arg_scope = value
	}

	// Process error message color setting
	key = "MSG_NOCOLOR"

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

		ErrorText("Error: Unexpected command parameter: \(arg)")
		exit(1)
	}
}

func main() {
	ProcessEnvironment()

	ProcessCommandLine()

	if arg_debug {
		DebugText("Client ID: \(arg_client_id)")
		DebugText("Scope:     \(arg_scope)")
	}

	if arg_client_id.isEmpty {
		ErrorText("Error: Missing environment variable \(github_client_id_name)")
		exit(1)
	}

	guard let access_token = Authorize()  else {
		exit(1)
	}

	print("Access Token: \(access_token)")
}

main()
