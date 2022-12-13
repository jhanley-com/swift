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

func execProgram(programName: String, args: [String]) -> (Int, String) {
	let task = Process()

	let path = findProgram(name: programName)

	if path.isEmpty {
		ErrorText("Error: Cannot find \(programName) in PATH")
		return (-1, "")
	}

	if arg_debug {
		DebugText("Location: \(path)")
	}

	task.executableURL = URL(fileURLWithPath: path)

	task.arguments = args

	let outputPipe = Pipe()

	task.standardOutput = outputPipe

	do {
		try task.run()
	} catch {
		ErrorText("\(error)")
		return (-1, "")
	}

	let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()

	let output = String(decoding: outputData, as: UTF8.self)

	task.waitUntilExit()

	let exitCode: Int = Int(task.terminationStatus)

	return (exitCode, output)
}

func findProgram(name: String) -> String {
#if os(Windows)
	// Windows PATH separator character
	let separator: Character = ";"
#else
	// Linux, macOS
	let separator: Character = ":"
#endif

	// Windows
	var env_path = ProcessInfo.processInfo.environment["Path"]

	if env_path == nil {
		env_path = ProcessInfo.processInfo.environment["PATH"]
	}

	guard let env_path = env_path else {
		return ""
	}

	let dirs = env_path.split(separator: separator)

	for dir in dirs {
		let path = makePath(String(dir), name)

		if FileManager.default.fileExists(atPath: path) {
			return path
		}
	}

	return ""
}

func fixPath(_ path: String) -> String {
#if os(Windows)
	let separator1 = "/"
	let separator2 = "\\"
#else
	// Linux, macOS
	let separator1 = "\\"
	let separator2 = "/"
#endif

	return path.replacingOccurrences(of: separator1, with: separator2)
}

func makePath(_ _path1: String, _ _path2: String) -> String {
	let path1 = fixPath(_path1)
	let path2 = fixPath(_path2)

	let path = NSString.path(withComponents: [path1, path2])

	return fixPath(path)
}
