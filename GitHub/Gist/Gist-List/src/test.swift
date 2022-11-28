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

func test() {
	// Sample data from Gist List
	// let filename = "TestData/list.json"
	let filename = "test.json"

	do {
		let url = URL(fileURLWithPath: filename)

		let content = try String(contentsOf: url, encoding: .utf8)

		let payload = content.replacingOccurrences(of: "public", with: "Public")

		if arg_debug {
			DebugText(payload)
		}

		guard let data = payload.data(using: .utf8) else {
			ErrorText("Error: Cannot parse Gist response data")
			return
		}

		let decoder = JSONDecoder()

		let items = try decoder.decode([GistListItemResponse].self, from: data)

		// for item in json.items {
		for item in items {
			// print("\(item.id)  \(item.description)  \(item.updated_at)")
			print_gist_list_item(item: item)
		}

		print("Total items: \(items.count)")
	} catch {
		ErrorText("Error: \(error)")
	}
}
