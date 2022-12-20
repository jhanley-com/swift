# Sign data using a Google Cloud service account

## Release Date
December 19, 2022

## Program License

MIT Licensed. Refer to copyright.txt and LICENSE for details.

## Program Description

Supports macOS, Linux and Windows.

This program reads a Google Cloud service account JSON key file, extracts the private key, and creates an RS256 (RSA + SHA256) signature. The signature is written as part of a JSON structure. The matching program `gcp-verify` reads the JSON structure and downloads the corresponding public certificate from Google's site.

This program duplicates the functionality of openssl:

`openssl dgst -sign private_key.pem -keyform PEM -sha256 -out example.sign example.data`

`openssl` generates a SHA256 hash and signs with a RSA private key. The signature is written as a binary file (example.sign).

This program generates a SHA256 hash and signs with the RSA private key from a service account JSON file and writes a JSON structure that includes the signature encoded (base64, base64url, hex). The signature generated, in binary, is identical.

## Signature file format

```
{
  "private_key_id": "same as service account JSON key file",
  "client_x509_cert_url": "same as service account JSON key file",
  "format": "base64",
  "signature": "encoded binary string"
}
```

The keys `private_key_id` and `client_x609_cert_url` are copies from the same keys in the service account JSON key file. Those fields are used by `gcp-verify` to download the public X509 certificate that matches the private key.

The key `signature` is the encoded RS256 (RSA + SHA256) binary signature.

`format` can be `base64`, `base64url`, `hex`.

Examples:
 - `gcp-sign --format=base64 filename`
 - `gcp-sign --format=base64url filename`
 - `gcp-sign --format=hex filename`

## Usage

`gcp-sign [OPTIONS] [filename]`

### OPTIONS
| Flag             | Description                 |
|------------------|-----------------------------|
| -h, --help       | Display help text           |
| -v, --version    | Display version information |
| --debug          | Enable Debug Mode           |
| --sa=path        | Path to service account JSON key file |
| --signature=path | Signature file to create. If not specified, write to stdout |
| --format=format  | Signature format. `base64` (default), `base64url`, `hex` |

### Environment variables
| Name            | Description                 |
|-----------------|-----------------------------|
| GOOGLE_APPLICATION_CREDENTIALS | Path to service account JSON key file |
| MSG_NOCOLOR     | `false` - Enable color in error messages (default) |
| MSG_NOCOLOR     | `true`  - Disable color in error messages |

### Notes

`filename` is the file to generate the signature from. If a filename is not specified, `stdin` is read instead.

The service account JSON key file can be specified on the command line or via the environment variable `GOOGLE_APPLICATION_CREDENTIALS`. The command line flag overrides the environment variable.

The signature can be written to `stdout` or to a file.

## Examples

#### Example 1: Read data from `stdin`, write signature to `stdout`, use service account specified by the environment variable `GOOGLE_APPLICATION_CREDENTIALS`:
 - `gcp-sign`

#### Example 2: Read data from `filename`, write signature to `stdout`, use service account specified by the environment variable `GOOGLE_APPLICATION_CREDENTIALS`:
 - `gcp-sign filename`

#### Example 3: Read data from `filename`, write signature to `stdout`, use service account `service_account.json`:
 - `gcp-sign --sa=service_account.json filename`

#### Example 4: Read data from `filename`, write signature to `filename.sig`, use service account `service_account.json`:
 - `gcp-sign --sa=service_account.json --signature=filename.sig filename`

## Verify

A matching program `gcp-verify` reads the signature file and validates the data signature. The `gcp-verify` program does not need access to the service account or private key. The public certificate is downloaded from Google during the verification process.

 - `gcp-verify --signature=filename.sig filename`

## Requirements

### Linux

#### Install OpenSSL.
`apt-get install openssl libssl-dev`

### macOS

#### Install OpenSSL.
`brew install openssl@1.1`

### Windows
Requires Visual Studio, OpenSSL and Swift installed on the system. The make tool is from Visual Studio.

#### Install Visual Studio:

 - Download link: https://visualstudio.microsoft.com/vs/community/

#### Install OpenSSL.

Download page: https://slproweb.com/products/Win32OpenSSL.html

Tested with "Win64 OpenSSL v1.1.1s" downloaded from:
 - Download link: https://slproweb.com/download/Win64OpenSSL-1_1_1s.msi

 Tested with "Win64 OpenSSL v3.0.7" downloaded from:
 - Download link: https://slproweb.com/download/Win64OpenSSL-3_0_7.msi

Note: Install the package built for developers.

#### Install Swift 5.7.2

 - Getting Started Page: https://www.swift.org/getting-started/
 - Download page: https://www.swift.org/download/

## Configure

### Linux
Modify the Makefile.linux to specify the OpenSSL installation path for `PATH_OPENSSL`.

### macOS
Modify the Makefile.macos to specify the OpenSSL installation path for `PATH_OPENSSL`.

### Windows
Modify the Makefile.w64 to specify the OpenSSL installation path for `PATH_OPENSSL`.

Create and download a Google Cloud service account JSON key. This program does not require any IAM roles or permissions assigned to the service account. This program signs data using the service account private key, no API calls to Google Cloud IAM are made.

 - https://cloud.google.com/iam/docs/creating-managing-service-account-keys

## Build

### Linux

Use the batch script `make.sh` or type:

`make -f Makefile.linux`

The C and Swift source files are compiled and the executable `gcp-sign` is placed in the build-linux directory.

### macOS

`make -f Makefile.macos`

The C and Swift source files are compiled and the executable `gcp-sign` is placed in the build-macos directory.

### Windows

Start a Visual Studio x64 Native Tools Command Prompt.

Use the batch script `make.bat` or type:

`nmake /f Makefile.w64`

The C and Swift source files are compiled and the executable `gcp-sign.exe` is placed in the build-windows directory.

## Tested Environments
 - Windows 10 - Swift version 5.7.2, Visual Studio 2022 x64, compiler version 19.35.32019
 - Ubuntu 22.04 - Swift version 5.7.2, gcc version 11.3.0
 - macOS Monterey 12.6.1 (Intel) - Swift version 5.7, clang version 14.0.0

## Limitations
 - None

## Known Bugs
 - None
