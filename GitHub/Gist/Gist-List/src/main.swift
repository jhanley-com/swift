/*****************************************************************************
* Date Created: 2022-11-22
* Last Update:  2022-11-22
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

let version = "0.90.0 (2022/11/22)"

// Set the environment variable GITHUB_TOKEN=personal_access_token
let github_token_name = "GITHUB_TOKEN"
var authToken = ""

// In test mode, list gists from sample data
var flag_testmode = false

// In debug mode, print additional information
var arg_debug = false

// This controls if coloring is disabled.
// This value is read from the environment:
// Windows: set MSG_NOCOLOR=true
// Linux: export MSG_NOCOLOR=true
var nocolor = false

var arg_public = false
var arg_secret = false

// Assume terminal size is 80 columns x 25 lines (rows)
var terminal_cols = 80
var terminal_lines = 24

func Version() {
	print("Version: \(version)")
}

func Usage() {
	BlueText("gist-list [OPTIONS]")
	BlueText("OPTIONS:")
	BlueText("    -h, --help       Display help text")
	BlueText("    -v, --version    Display version information")
	BlueText("    -p, --public     Show only public gists")
	BlueText("    -s, --secret     Show only secret gists")
	BlueText("    --debug          Enable Debug Mode")
	BlueText("    --test           List gists from sample data")
}

func ProcessEnvironment() {
	// Process GitHub Token

	var key = github_token_name

	if let value = ProcessInfo.processInfo.environment[key] {
		authToken = value
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

		if arg == "-p" || arg == "--public" {
			arg_public = true
			continue
		}

		if arg == "-s" || arg == "--secret" {
			arg_secret = true
			continue
		}

		if arg == "--debug" {
			arg_debug = true
			continue
		}

		if arg == "--test" {
			flag_testmode = true
			continue
		}

		ErrorText("Error: Unexpected command parameter: \(arg)")
		exit(1)
	}
}

func ProcessTerminal() {
	var (code, cols, lines) = getTerminalWindowSize()

	if code != 0 {
		// Assume terminal size is 80 columns x 25 lines (rows)
		cols = 80
		lines = 24
	}

	terminal_cols = cols
	terminal_lines = lines

	// DebugText("Cols: \(cols)")
	// DebugText("Lines: \(lines)")
}

func GistGetFirstFilename(item: GistListItemResponse) -> String {
	for (_, value) in item.files {
		return value.filename
	}

	return "NO_FILES"
}

func GistGetFileCount(item: GistListItemResponse) -> String {
	let count = item.files.count

	if count == 0 {
		return "0 files"
	}

	if count == 1 {
		return "1 file"
	}

	return "\(count) files"
}

func print_gist_list_item(item: GistListItemResponse) {
	var id_len = 32
	var description_len = 32
	var file_len = 7
	var date_len = 10
	var public_len = 6

	if terminal_cols < 75 {
		id_len = 32
		description_len = 32
		file_len = 0
		public_len = 0
		date_len = 0
	} else if terminal_cols <= 83 {
		id_len = 32
		description_len = 32
		file_len = 0
		public_len = 6
		date_len = 0
	} else if terminal_cols <= 93 {
		id_len = 32
		description_len = 32
		file_len = 7
		public_len = 6
		date_len = 0
	}

	let id = item.id.padding(toLength: id_len, withPad: " ", startingAt: 0)

	var description = item.description ?? ""

	if description.isEmpty {
		let filename = GistGetFirstFilename(item: item)
		description = filename.padding(toLength: description_len, withPad: " ", startingAt: 0)
	} else {
		description = description.padding(toLength: description_len, withPad: " ", startingAt: 0)
	}

	var count = ""
	if file_len > 0 {
		let files = GistGetFileCount(item: item)
		count = files.padding(toLength: file_len, withPad: " ", startingAt: 0)
	}

	var Public = ""

	if item.Public == true {
		Public = "public"
	} else {
		// FIX - This does not work on Windows. It does work on Linux and macOS
#if os(Windows)
		Public = "secret"
#else
		if nocolor == true {
			Public = "secret"
		} else {
			Public = "\u{001B}[31m" + "secret" + "\u{001B}[0m"
		}
#endif
	}

	var updated_at = ""
	if date_len > 0 {
		updated_at = item.updated_at.padding(toLength: date_len, withPad: " ", startingAt: 0)
	}

	if public_len == 0 {
		print("\(id)  \(description)")
	} else if file_len == 0 && date_len == 0 {
		print("\(id)  \(description)  \(Public)")
	} else if file_len == 0 {
		print("\(id)  \(description)  \(Public) \(updated_at)")
	} else if date_len == 0 {
		print("\(id)  \(description)  \(count)  \(Public)")
	} else {
		print("\(id)  \(description)  \(count)  \(Public) \(updated_at)")
	}
}

func gist_list() {
	// let base_uri = "https://api.github.com/gists/public"
	let base_uri = "https://api.github.com/gists"

	// ------------------------------------------------------------
	// FIX - Incorrect Pagination Code
	// This code is performing pagination wrong. URLs are constructed
	// from values instead of parsing the HTTP response header "link".
	//
	// See this document for more details:
	// https://docs.github.com/en/rest/overview/resources-in-the-rest-api#link-header
	// ------------------------------------------------------------

	let per_page = 30
	var total_items = 0

	for page in 1...100 {
		let uri = "\(base_uri)?per_page=\(per_page)&page=\(page)"

		let response = gist_http_get(
					authToken: authToken,
					uri: uri)

		guard let response = response else {
			ErrorText("Error: Request Failed")
			return
		}

		do {
			let decoder = JSONDecoder()

			let items = try decoder.decode([GistListItemResponse].self, from: response)

			// print()
			// print("results:")
			// print(results)

			if items.count == 0 {
				break
			}

			total_items += items.count

			for item in items {
				if arg_secret == true && item.Public == true {
					continue
				}

				if arg_public == true && item.Public == false {
					continue
				}

				print_gist_list_item(item: item)
			}
		} catch {
			ErrorText("Error: \(error)")
			ErrorText(String(data: response, encoding: .utf8)!)
			ErrorText(error.localizedDescription)
			return
		}
	}
	print("Total items: \(total_items)")
}

func main() {
	ProcessEnvironment()

	ProcessTerminal()

	ProcessCommandLine()

	if authToken.isEmpty {
		ErrorText("Error: Missing environment variable \(github_token_name)")
		exit(1)
	}

	if flag_testmode == true {
		print("Running in Test Mode")
		print()

		test()
		exit(0)
	}

	if arg_public && arg_secret {
		ErrorText("Error: Do not specify both --public and --secret. Nothing will be displayed.")
		exit(1)
	}

	gist_list()
}

main()
