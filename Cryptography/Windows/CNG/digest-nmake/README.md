# Generate a digest using Windows CNG Libraries

## Release Date
March 6, 2023

---
## Program License

MIT Licensed. Refer to [copyright.txt](copyright.txt) and [LICENSE](LICENSE) for details.

---
## Program Description

Supports Windows only. This program integrates with the Windows `Cryptography Next Generation (CNG)` library (`bcrypt.dll`) and does not use third party libraries such as OpenSSL.

This program generates a digest from stdin or a file. Supported digests are md5, sha1, sha256, sha384 and sha512. Output formats are base64, base64url, binary and hex.

The cryptography libraries that exist for Swift do not support Windows, only Linux and macOS. This program is my first step in learning how to integrate Swift with native Windows libraries for cryptography.

---
## Installation
This package includes Inno Setup configuration files to create a Windows installer. Run the command `make installer` to build the setup program. The installer is written to `build-windows/digest-installer.exe`.

To build and launch the installer, run `make install`.

Installation requires the [Inno Setup Compiler](https://www.innosetup.com/). Tested with version 6.2.1

---
## Usage

`digest [OPTIONS] [FILENAME]`

---
### OPTIONS
| Flag             | Description                       |
|------------------|----------------------------------------------------------|
| -h, --help       | Display help text                                        |
| -v, --version    | Display version information                              |
| --debug          | Enable Debug Mode                                        |
| --md5            | Create an MD5 digest                                     |
| --sha1           | Create a SHA1 digest                                     |
| --sha256         | Create a SHA256 digest                                   |
| --sha384         | Create a SHA384 digest                                   |
| --sha512         | Create a SHA512 digest                                   |
| --openssl        | Print the digest in OpenSSL format                       |
| --coreutils      | Print the digest in coreutils format                     |
| --format=format  | Digest format. base64, base64url, binary, hex (default)  |
| --out=filename   | Name of file to write. If not specified, write to stdout |
| FILENAME         | Name of file to read. If not specified, read from stdin  |

---
### Notes

if binary format is selected, `--format=binary`, you must either specify `--out=filename` or redirect `stdout` to a file or a pipe. Otherwise the following error is displayed:

`Error: Cannot write binary data to stdout`

For example, these methods will work:
 - `digest test.data --sha256 --format=binary --out=test.out`
 - `digest test.data --sha256 --format=binary > test.out`
 - `digest test.data --sha256 --format=binary | another_program`

This method will report the error:
 - `digest test.data --sha256 --format=binary`

---
### Environment variables
| Name            | Description                 |
|-----------------|-----------------------------|
| MSG_NOCOLOR     | `false` - Enable color in error messages (default) |
| MSG_NOCOLOR     | `true`  - Disable color in error messages |

---
## Examples

#### Example 1: generate the SHA256 digest from the file `test.data`:
 - `digest --sha256 test.data`

#### Example 2: generate the SHA256 digest from the file `test.data`, write binary signature to file `test.out`:
 - `digest --sha256 --format=binary --out=test.out test.data`

---
## Requirements

### Windows
Requires Visual Studio 2019 and Swift installed on the system. The make tool is from Visual Studio.

#### Install Visual Studio 2019:
 - Important: Visual Studio 2022 Preview 2.0 breaks the Swift compiler on Windows.
 - Download link: https://visualstudio.microsoft.com/vs/community/

#### Install Swift 5.7.2

 - Getting Started Page: https://www.swift.org/getting-started/
 - Download page: https://www.swift.org/download/

---
## Configure

### Windows
No configuration is required. Some tests execute the OpenSSL command line program `openssl`.

---
## Build

### Windows

Start a Visual Studio x64 Native Tools Command Prompt.

Use the batch script `make.bat` or type:

`nmake /f Makefile.w64`

The source files are compiled and the executable `digest.exe` is placed in the `build-windows` directory.

---
## Test

The source file `test.swift` contains several tests to validate sha256 results. Some tests execute the OpenSSL command line program `openssl`.

`make test` or `nmake /f Makefile.w64 test`

---
## Tested Environments
 - Windows 10 x64 version 10.0.19045.2486
   - Windows Cryptographic Primitives Library (bcrypt.dll) version 10.0.19041.2486 (1/11/2023)
   - Swift version 5.7.2
   - Visual Studio 2019 x64, compiler version 19.29.30147

---
## Limitations
 - Visual Studio 2022 Preview 2.0 breaks the Swift Compiler on Windows.
   - Visual Studio 2022 x64, compiler version 19.35.32019 works.
   - Visual Studio 2022 x64, compiler version 19.35.32124 fails.
 - Solution: build with Visual Studio 2019.

---
## Known Issues
### Swift Version 5.7.3
Builds fail with the error `error: missing required module 'SwiftShims'`.

---
## Known Bugs
 - None
