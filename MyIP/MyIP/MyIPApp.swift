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

@main
struct MyIPApp: App {
    // @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
	// needed because WindowGroup scene seems have default
	// handler for external events, so opens new scene even
	// if no onOpenURL or userActivity callbacks are present
        .handlesExternalEvents(matching: [])
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
	func application(_ application: NSApplication, open urls: [URL]) {
		print("Unhandled: \(urls)")
	}
	
	func applicationDidBecomeActive(_ notification: Notification) {
		// Restore first minimized window if app became active and no one window
		// is visible
		if NSApp.windows.compactMap({ $0.isVisible ? Optional(true) : nil }).isEmpty {
			 NSApp.windows.first?.makeKeyAndOrderFront(self)
		}
	}
}
