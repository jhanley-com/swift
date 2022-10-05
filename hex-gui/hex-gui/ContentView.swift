/*****************************************************************************
* Date Created: 2022-10-04
* Last Update:  2022-10-04
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
    @State private var text = ""

    var body: some View {
        let myFont = Font
            .system(size:14)
            .monospaced()
            
        VStack {
            TextEditor(text: .constant(self.text))
                .font(myFont)
                .frame(minWidth: 700, minHeight: 500)

            HStack {
                // Open button.
                Button(action: {
                    let openURL = showOpenPanel()
                    if openURL != nil {
                        text = processFile(openURL)
                    }
                }, label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Open")
                    }
                    .frame(width: 80)
                })
            }
            .padding(20)
        }
    }
    
    func showOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()

        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true

        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
