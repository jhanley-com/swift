# Create a Google OAuth Access Token

## Release Date
December 14, 2022

---
## Program License

MIT Licensed. Refer to copyright.txt and LICENSE for details.

---
## Program Description

Supports macOS, Linux and Windows.

This program creates a Google OAuth Access Token from a Service Account JSON key file. The access token details are put into a JSON structure and written to stdout or a file.

---
## Token file format

```
{
  "access_token": "access token received from Google",
  "expires_in": "number of seconds until the token expires typically 3599",
  "issued": "time the token was issued"
  "token_type": "Bearer"
}
```

---
## Usage

`gcp-access-token [OPTIONS]`

---
### OPTIONS
| Flag             | Description                 |
|------------------|-----------------------------|
| -h, --help       | Display help text           |
| -v, --version    | Display version information |
| --debug          | Enable Debug Mode           |
| --out=filename   | Filename to save token. If not specified, write to stdout |
| --sa=path        | Path to service account JSON key file |
| --scopes=scopes  | Scopes to request (comma separated). Defaults to cloud-platform |

---
### Environment variables
| Name            | Description                 |
|-----------------|-----------------------------|
| GOOGLE_APPLICATION_CREDENTIALS | Path to service account JSON key file |
| MSG_NOCOLOR     | `false` - Enable color in error messages (default) |
| MSG_NOCOLOR     | `true`  - Disable color in error messages |

### Notes

The service account JSON key file can be specified on the command line or via the environment variable `GOOGLE_APPLICATION_CREDENTIALS`. The command line flag overrides the environment variable.

If `--scopes` is not specified, the default scope is `https://www.googleapis.com/auth/cloud-platform`

---
## Examples

#### Example 1: Create an access token, write the token to `stdout`, use service account specified by the environment variable `GOOGLE_APPLICATION_CREDENTIALS`:
 - `gcp-access-token`

#### Example 2: Read data from `filename`, write signature to `stdout`, use service account specified by the environment variable `GOOGLE_APPLICATION_CREDENTIALS`:

#### Example 2: Create an access token, write the token to `filename`, use service account specified by the environment variable `GOOGLE_APPLICATION_CREDENTIALS`:
 - `gcp-access-token filename --out=filename`

#### Example 3: Read data from `filename`, write signature to `stdout`, use service account `service_account.json`:
 - `gcp-access-token --sa=service_account.json`

---
## Requirements

### Linux

#### Install OpenSSL.
`apt-get install openssl libssl-dev`

### macOS

#### Install OpenSSL.
`brew install openssl@1.1`

### Windows
Requires Visual Studio 2019, OpenSSL and Swift installed on the system. The make tool is from Visual Studio.

#### Install Visual Studio 2019:
 - Important: Visual Studio 2022 Preview 2.0 breaks the Swift compiler on Windows.
 - Download link: https://visualstudio.microsoft.com/vs/community/

#### Install OpenSSL.

Download page: https://slproweb.com/products/Win32OpenSSL.html

Tested with "Win64 OpenSSL v1.1.1s" downloaded from:
 - Download link: https://slproweb.com/download/Win64OpenSSL-1_1_1s.msi

 Tested with "Win64 OpenSSL v3.0.7" downloaded from:
 - Download link: https://slproweb.com/download/Win64OpenSSL-3_0_7.msi

Note: Install the package built for developers.

#### Install Swift 5.7

 - Getting Started Page: https://www.swift.org/getting-started/
 - Download page: https://www.swift.org/download/

---
## Configure

### Linux
Modify the Makefile.linux to specify the OpenSSL installation path for `PATH_OPENSSL`.

### macOS
Modify the Makefile.macos to specify the OpenSSL installation path for `PATH_OPENSSL`.

### Windows
Modify the Makefile.w64 to specify the OpenSSL installation path for `PATH_OPENSSL`.

Create and download a Google Cloud service account JSON key.

 - https://cloud.google.com/iam/docs/creating-managing-service-account-keys

---
## Build

### Linux

Use the batch script `make.sh` or type:

`make -f Makefile.linux`

The C and Swift source files are compiled and the executable `gcp-access-token` is placed in the build-linux directory.

### macOS

`make -f Makefile.macos`

The C and Swift source files are compiled and the executable `gcp-access-token` is placed in the build-macos directory.

### Windows

Start a Visual Studio x64 Native Tools Command Prompt.

Use the batch script `make.bat` or type:

`nmake /f Makefile.w64`

The C and Swift source files are compiled and the executable `gcp-access-token.exe` is placed in the build-windows directory.

---
## Tested Environments
 - Windows 10 - Swift version 5.7.1, Visual Studio 2019 x64, compiler version 19.29.30147
 - Ubuntu 22.04 - Swift version 5.7.1, gcc version 11.3.0
 - macOS Monterey 12.6.1 (Intel) - Swift version 5.7.1, clang version 14.0.0

---
## Limitations
 - Visual Studio 2022 Preview 2.0 breaks the Swift Compiler on Windows.
   - Visual Studio 2022 x64, compiler version 19.35.32019 works.
   - Visual Studio 2022 x64, compiler version 19.35.32124 fails.
 - Solution: build with Visual Studio 2019.

---
## Known Bugs
 - None
