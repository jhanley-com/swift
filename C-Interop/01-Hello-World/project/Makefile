OBJDIR = obj
OUTDIR = build

CFLAGS = /c /MD /W4 -Ih

# /MD    Creates a multithreaded DLL using MSVCRT.lib.
# /MDd   Creates a debug multithreaded DLL using MSVCRTD.lib.

all: $(OBJDIR) $(OUTDIR) $(OUTDIR)/main.exe

$(OBJDIR):
	mkdir $(OBJDIR)

$(OUTDIR):
	mkdir $(OUTDIR)

$(OUTDIR)/main.exe: $(OBJDIR)/hello-world.obj src/main.swift Makefile
	swiftc -import-objc-header h/hello-world.h src/main.swift $(OBJDIR)/hello-world.obj -o $(OUTDIR)/main.exe

$(OBJDIR)/hello-world.obj: src/hello-world.c h/hello-world.h Makefile
	cl $(CFLAGS) src/hello-world.c /Fo$@

.PHONY: clean   
clean:
	del /q $(OBJDIR) $(OUTDIR)
	rmdir $(OBJDIR)
	rmdir $(OUTDIR)
