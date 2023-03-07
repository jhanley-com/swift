#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <bcrypt.h>
#include <stdio.h>
#include "string.h"

#pragma comment (lib, "bcrypt.lib")
#pragma comment (lib, "ncrypt.lib")

typedef	__int32			nint32;
typedef	unsigned __int32	nuint32;

// Functions for Win32 consoles (cmd.exe)
extern	int setupConsole(void);
extern	int restoreConsole(void);
extern	int getConsoleWindowsSize(nint32 *cols, nint32 *rows);

// Functions for Win32 error messages
extern	const char *Win32FormatMessage(nint32 status);
extern	void Win32FreeMessage(const char *ptr);
