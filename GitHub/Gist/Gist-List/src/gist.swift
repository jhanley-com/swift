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

// I copied the schema and saved in TestData/list.schema
// https://docs.github.com/en/rest/gists/gists#list-public-gists

struct GistListFileResponse: Codable {
	var filename: String
	var type: String
	var language: String?
	var raw_url: String
	var size: Int
}

struct GistUserResponse: Codable {
	var login: String
	var id: Int
	var node_id: String
	var avatar_url: String
	var gravatar_id: String
	var url: String
	var html_url: String
	var followers_url: String
	var following_url: String
	var gists_url: String
	var starred_url: String
	var subscriptions_url: String
	var organizations_url: String
	var repos_url: String
	var events_url: String
	var received_events_url: String
	var type: String
	var site_admin: Bool
}

struct GistListItemResponse: Codable {
	var url: String
	var forks_url: String
	var commits_url: String
	var id: String
	var node_id: String
	var git_pull_url: String
	var git_push_url: String
	var html_url: String
	var files: Dictionary<String, GistListFileResponse>
	var Public: Bool
	var created_at: String
	var updated_at: String
	var description: String?
	var comments: Int
	var user: String?
	var comments_url: String
	var owner: GistUserResponse
	var truncated: Bool
}
