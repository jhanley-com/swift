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

func DebugText(_ msg: String) {
	print(msg)
}

func BlueText(_ msg: String) {
	if nocolor == false {
		print("\u{001B}[01;34m" + msg + "\u{001B}[0m")
	} else {
		print(msg)
	}
}

func ErrorText(_ msg: String) {
	if nocolor == false {
		print("\u{001B}[01;31m" + msg + "\u{001B}[0m")
	} else {
		print(msg)
	}
}
