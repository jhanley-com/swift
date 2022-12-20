#include <sys/ioctl.h>
#include <unistd.h>
#include "c-interface.h"

int getConsoleWindowsSize(nint32 *cols, nint32 *rows)
{
	struct winsize w;
	ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);

	*cols = w.ws_col;
	*rows = w.ws_row;

	// printf("DEBUG: cols: %d\n", *cols);
	// printf("DEBUG: rows: %d\n", *rows);

	return 0;
}
