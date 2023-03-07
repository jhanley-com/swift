/*****************************************************************************
* Date Created: 2022-12-23
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

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include "c-interface.h"

#define ENABLE_VIRTUAL_TERMINAL_PROCESSING  0x0004
#define STD_INPUT_HANDLE ((DWORD)-10)
#define STD_OUTPUT_HANDLE ((DWORD)-11)
#define STD_ERROR_HANDLE ((DWORD)-12)

static int stdoutInited = 0;
static HANDLE stdoutHandle;
static DWORD outModeInit;

int setupConsole(void)
{
	// printf("setup console\n");

	DWORD outMode = 0;
	stdoutHandle = GetStdHandle(STD_OUTPUT_HANDLE);

	if(stdoutHandle == INVALID_HANDLE_VALUE)
	{
		return GetLastError();
	}

	if(!GetConsoleMode(stdoutHandle, &outMode))
	{
		return GetLastError();
	}

	outModeInit = outMode;

	// Enable ANSI escape codes
	outMode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;

	if(!SetConsoleMode(stdoutHandle, outMode))
	{
		return GetLastError();
	}	

	stdoutInited = 1;
	return 0;
}

int restoreConsole(void)
{
	// printf("restore console\n");

	if (stdoutInited == 0) {
		return 0;
	}

	// Reset colors
	printf("\x1b[0m");	

	// Reset console mode
	if(!SetConsoleMode(stdoutHandle, outModeInit))
	{
		return GetLastError();
	}

	return 0;
}

int getConsoleWindowsSize(nint32 *cols, nint32 *rows)
{
	CONSOLE_SCREEN_BUFFER_INFO csbi;

	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi);

	*cols = csbi.srWindow.Right - csbi.srWindow.Left + 1;
	*rows = csbi.srWindow.Bottom - csbi.srWindow.Top + 1;

	// printf("cols: %d\n", *cols);
	// printf("rows: %d\n", *rows);

	return 0;
}
