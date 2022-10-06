/*****************************************************************************
* Date Created: 2022-10-05
* Last Update:  2022-10-05
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

import SwiftUI

struct ContentView: View {
	@Environment(\.scenePhase) var scenePhase
	@State var myip = "Checking ..."
	@State var refresh = true
	@State private var selectedServer = "random"
	@State private var selectedInterval = "15 minutes"

	// Use a space instead of empty string so that
	// the GUI keeps the controls in the same place
	@State private var lastError = " "

	// FIX: combine servers and fservers
	let servers = [
		"random",
		"aws",
		"icanhazip",
		"ifconfig",
		"ipecho",
		"ipify",
		"ipinfo",
		"jhanley"
	]

	private struct Interval: Identifiable {
		let name: String
		let duration: Int
		var id: String { name }
	}

	// Some of the servers will block callers if they make requests too often
	private let intervals: [Interval] = [
		Interval(name: "15 seconds", duration: 15),	// Only use while debugging
		Interval(name: "30 seconds", duration: 30),	// Only use while debugging
		Interval(name: "60 seconds", duration: 60),	// Only use while debugging
		Interval(name: "2 minutes", duration: 120),	// Only use while debugging
		Interval(name: "5 minutes", duration: 300),
		Interval(name: "15 minutes", duration: 900),
		Interval(name: "30 minutes", duration: 1800),
		Interval(name: "60 minutes", duration: 3600),
		Interval(name: "3 hours", duration: 3600 * 3),
		Interval(name: "6 hours", duration: 3600 * 6),
		Interval(name: "12 hours", duration: 3600 * 12),
		Interval(name: "24 hours", duration: 3600 * 24)
	]

	@State var timer: Timer.TimerPublisher = Timer.publish(every: 15, on: .main, in: .common)

	var body: some View {
		let myFont = Font.system(size:16).monospaced()

		VStack {
			Section {
				Picker("Server:", selection: $selectedServer) {
					ForEach(servers, id: \.self) {
						Text($0)
					}
				}
				.onChange(of: selectedServer) { _ in
					getIP()
				}
				.frame(width: 200)

				Picker("Interval:", selection: $selectedInterval) {
					ForEach(intervals) { interval in
						Text(interval.name)
					}
				}
				.onChange(of: selectedInterval) { name in
					changeTimerInterval(to: name)
				}
				.frame(width: 200)

				Spacer()

				Text(myip).font(myFont).textSelection(.enabled)
			}
			Spacer()
			Text(lastError)
			Button("Refresh") {
				getIP()
			}
		}
		.padding()
		.onAppear {
			getIP()
			_ = timer.connect()
		}
		.onChange(of: scenePhase) { newPhase in
			if newPhase == .active {
#if DEBUG
				print("Active")
#endif
				refresh = true
				getIP()
			} else if newPhase == .inactive {
#if DEBUG
				print("Inactive")
#endif
				refresh = false
			} else if newPhase == .background {
#if DEBUG
				print("Background")
#endif
				refresh = false
			}
		}
		.onReceive(timer) { _ in
			getIP()
		}
		.frame(minWidth: 200, minHeight: 200)
		.frame(maxWidth: 600, maxHeight: 600)
	}

	func clearLastError() {
		// Use a space instead of empty string so that
		// the GUI keeps the controls in the same place
		lastError = " "
	}

	func changeTimerInterval(to name: String) {
#if DEBUG
		print("Interval changed")
		print("name = \(name)")
#endif

		timer.connect().cancel()

		for interval in intervals {
			if interval.name == name {
#if DEBUG
				print("Setting new duration: \(interval.duration)")
#endif

				timer = Timer.publish(every: Double(interval.duration), on: .main, in: .common)
				_ = timer.connect()

				return
			}
		}
	}

	func getIP() {
		let fservers = [
			getIP_aws,
			getIP_icanhazip,
			getIP_ifconfig,
			getIP_ipecho,
			getIP_ipify,
			getIP_ipinfo,
			getIP_jhanley
		]

		switch selectedServer {
			case "aws":
				getIP_aws()
			case "icanhazip":
				getIP_icanhazip()
			case "ifconfig":
				getIP_ifconfig()
			case "ipecho":
				getIP_ipecho()
			case "ipify":
				getIP_ipify()
			case "ipinfo":
				getIP_ipinfo()
			case "jhanley":
				getIP_jhanley()
			case "random":
				let index = Int(arc4random_uniform(UInt32(fservers.count)))
				fservers[index]()
			default:
				getIP_aws()
		}
	}

	// Json that includes the key "ip"
	func getIP_fromJsonResponse_ip(_ url: URL?) {
		if refresh == false {
#if DEBUG
			print("scenePhase: \(scenePhase)")
			print("SKIP")
#endif
			return
		}

		clearLastError()

		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
			guard error == nil else {
				myip = ""
#if DEBUG
				print("error: \(error!)")
#endif
				lastError = "\(error?.localizedDescription ?? "")"
				return
			}

			let httpStatus = response as! HTTPURLResponse

#if DEBUG
			print("Status Code: \(httpStatus.statusCode)")
#endif

			if httpStatus.statusCode < 200 || httpStatus.statusCode >= 300 {
				myip = ""
				lastError = "HTTP Status Code: \(httpStatus.statusCode)"
				return
			}

			guard let data = data else{
				myip = ""
#if DEBUG
				print("no data")
#endif
				lastError = "no data"
				return
			}

			clearLastError()

			let decoder = JSONDecoder()

			do {
				let results = try decoder.decode([String: String].self, from: data)
#if DEBUG
				print(results)
#endif

				if let ip = results["ip"] {
					myip = ip.trimmingCharacters(in: .whitespacesAndNewlines)

					let df = DateFormatter()
					df.dateFormat = "HH:mm:ss"
					let currentTime = df.string(from: Date())
					lastError = "Updated: \(currentTime)"

#if DEBUG
					print("\(currentTime): myip = \(myip)")
#endif
				}
			} catch {
#if DEBUG
				print(error)
#endif
				return
			}
		}
		task.resume()

		return
	}

	func getIP_fromStringResponse(_ url: URL?) {
		if refresh == false {
#if DEBUG
			print("scenePhase: \(scenePhase)")
			print("SKIP")
#endif
			return
		}

		clearLastError()

		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
			guard error == nil else {
				myip = ""
#if DEBUG
				print("error: \(error!)")
#endif
				lastError = "\(error?.localizedDescription ?? "")"
				return
			}

			let httpStatus = response as! HTTPURLResponse

#if DEBUG
			print("Status Code: \(httpStatus.statusCode)")
#endif

			if httpStatus.statusCode < 200 || httpStatus.statusCode >= 300 {
				myip = ""
				lastError = "HTTP Status Code: \(httpStatus.statusCode)"
				return
			}

			guard let data = data else{
				myip = ""
#if DEBUG
				print("no data")
#endif
				lastError = "no data"
				return
			}

			clearLastError()

			let ip = String(decoding: data, as: UTF8.self)
			myip = ip.trimmingCharacters(in: .whitespacesAndNewlines)

			let df = DateFormatter()
			df.dateFormat = "HH:mm:ss"
			let currentTime = df.string(from: Date())
#if DEBUG
			print("\(currentTime): myip = \(myip)")
#endif
			lastError = "Updated: \(currentTime)"
		}
		task.resume()

		return
	}

	func getIP_aws() {
#if DEBUG
		print("getIP_aws()")
#endif

		let url = URL(string: "https://checkip.amazonaws.com/")

		getIP_fromStringResponse(url)
	}

	func getIP_icanhazip() {
#if DEBUG
		print("getIP_icanhazip()")
#endif

		let url = URL(string: "https://icanhazip.com")

		getIP_fromStringResponse(url)
	}

	func getIP_ifconfig() {
#if DEBUG
		print("getIP_ifconfig()")
#endif

		let url = URL(string: "https://ifconfig.me")

		getIP_fromStringResponse(url)
	}

	func getIP_ipecho() {
#if DEBUG
		print("getIP_ipecho()")
#endif

		let url = URL(string: "https://ipecho.net/plain")

		getIP_fromStringResponse(url)
	}

	func getIP_ipify() {
#if DEBUG
		print("getIP_ipify()")
#endif

		// String response
		// let url = URL(string: "https://api.ipify.org")
		// getIP_fromStringResponse(url)

		// JSON response
		let url = URL(string: "https://api.ipify.org?format=json")
		getIP_fromJsonResponse_ip(url)
	}

	func getIP_ipinfo() {
#if DEBUG
		print("getIP_ipinfo()")
#endif

		// String response
		// let url = URL(string: "https://ipinfo.io/ip")
		// getIP_fromStringResponse(url)

		// JSON response
		let url = URL(string: "https://ipinfo.io/json")
		getIP_fromJsonResponse_ip(url)
	}

	func getIP_jhanley() {
#if DEBUG
		print("getIP_jhanley()")
#endif

		let url = URL(string: "https://www.jhanley.com/myip")

		getIP_fromStringResponse(url)
	}
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
#endif
