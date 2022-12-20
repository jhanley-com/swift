# Windows Installer for Swift Programs:
 - gcp-access-token
 - gcp-sign
 - gcp-verify

## Release Date
December 19, 2022

---
## Program License

MIT Licensed. Refer to copyright.txt and LICENSE for details.

---
## Program Description

This folder contains a Windows installer based up Inno Setup versino 6.2.1: https://jrsoftware.org/isinfo.php

The following programs are installed:
 - gcp-access-token
 - gcp-sign
 - gcp-verify

## Requirements

### Install Swift 5.7.2

 - Getting Started Page: https://www.swift.org/getting-started/
 - Download page: https://www.swift.org/download/

## Setup
 - Run the tool `get_vc_redist.bat` to download the Visual Studio Runtime package. That file is downloaded to the `VC` directory.
 - Run the tool `get_swift_dlls.bat` to copy the required Swift runtime DLLs. This requires that Swift is installed on the system. The Swift DLLs are copied to the `DLL` directory.

---
## Tested Environments
 - Windows 10 x64 - Swift version 5.7.2

## Build Installer
Run the tool `build.bat` to create the Windows 64-bit installable package. The file generated is `google-cloud-service-account-tools.exe`.

---
## Known Issues

---
## Known Bugs
 - None
