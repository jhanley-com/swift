import Swifter
import Dispatch
import Foundation

let version = "0.90.0 (2022/10/23)"

let mycss = """
table {
  border: 1px solid black;
  border-collapse: collapse;
  width: 100%;
}
th, td {
  border: 1px solid #ddd; padding: 8px;
}
th {
  padding-top: 12px;
  padding-bottom: 12px;
  text-align: left;
  background-color: #4C8BF5;
  color: white;
}
"""

let server = HttpServer()

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}

// This allows favicon.ico to be served
server["/:path"] = shareFilesFromDirectory("./public")

server["/"] = { request in
	scopes {
		html {
			head {
				title { inner = "Container Request and Environment" }
				style { inner = mycss }
			}

			body {
				h3 { inner = "Program Version: \(version)" }
				h3 { inner = "Date: \(Date())" }
				let tz = TimeZone.current.abbreviation() ?? ""
				h3 { inner = "Time Zone: \(tz)" }
				h3 { inner = "Address: \(request.address ?? "unknown")" }
				h3 { inner = "Url: \(request.path)" }
				h3 { inner = "Method: \(request.method)" }

				h3 { inner = "Query:" }

				table(request.queryParams) { param in
					tr {
						td { inner = param.0 }
						td { inner = param.1 }
					}
				}

				h3 { inner = "Environment:" }

				let environment = ProcessInfo.processInfo.environment.sorted(by: {$0.0 < $1.0})

				table(environment) { env in
					tr {
						td { inner = env.0 }
						td { inner = env.1 }
					}
				}

				h3 { inner = "Headers:" }

				let headers = request.headers.sorted(by: {$0.0 < $1.0})

				table(headers) { header in
					tr {
						td { inner = header.0 }
						td { inner = header.1 }
					}
				}

				let cwd = FileManager.default.currentDirectoryPath

				h3 { inner = "Current Directory Path: \(cwd)" }

				let raw_files = build_raw_file_list(cwd)

				let files = raw_files.sorted(by: {$0.0 < $1.0})

				table(files) { file in
					tr {
						td { inner = file.0 }
						td { inner = file.1 }
					}
				}

				br {}

				center {
					footer { inner = "Copyright (c) 2022, John J. Hanley" }
					a {
						inner = "jhanley.com"
						href = "https://www.jhanley.com"
					 }
				}

				br {}
			}
		}
	}(request)
}

func build_raw_file_list(_ cwd: String) -> [String: String] {
	var files = [String: String]()

	let entries = FileManager.default.enumerator(atPath: cwd)

	while let entry = entries?.nextObject() {
		let name = entry as! String

		if name.starts(with: ".build") {
			continue
		}

		var value = ""

		let u = URL(fileURLWithPath: name)

		if u.isDirectory {
			value = "&lt;directory&gt;"
		} else {
			do {
				let attribute = try FileManager.default.attributesOfItem(atPath: name)

				let size = attribute[FileAttributeKey.size] as? Int ?? 0
				value = String(size)
			} catch {
				print("Error: file \(name): \(error)")
			}
		}

		files[name] = value
	}

	return files
}

let semaphore = DispatchSemaphore(value: 0)
do {
    let port = UInt16(ProcessInfo.processInfo.environment["PORT"] ?? "8080")
    try server.start(port!, forceIPv4: true)
    print("Server has started. Listening on port \(try server.port())")
    semaphore.wait()
} catch {
    print("Server start error: \(error)")
    semaphore.signal()
}
