/*****************************************************************************
* Date Created: 2022-12-12
* Last Update:  2022-12-18
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

#include "c-interface.h"

const char *Win32FormatMessage(DWORD status)
{
	LPVOID lpMessageBuffer = NULL;
	HMODULE h = LoadLibrary("NTDLL.DLL");

	DWORD flags = FORMAT_MESSAGE_ALLOCATE_BUFFER | 
		FORMAT_MESSAGE_FROM_SYSTEM | 
		FORMAT_MESSAGE_FROM_HMODULE |
		FORMAT_MESSAGE_MAX_WIDTH_MASK;

	FormatMessage( 
		flags,
		h, 
		status,
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR) &lpMessageBuffer,  
		0,  
		NULL);

	FreeLibrary(h);

	return (const char *)lpMessageBuffer;
}

void Win32FreeMessage(const char *ptr)
{
	// Free the buffer allocated by the system.
	LocalFree((HLOCAL)ptr); 
}
