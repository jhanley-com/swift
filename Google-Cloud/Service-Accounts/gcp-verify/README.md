# Verify data using a Google Cloud service account public key

## Release Date
December 12, 2022

## Program License

MIT Licensed. Refer to copyright.txt and LICENSE for details.

## Program Description

Supports Linux and Windows in this release. I have tested on macOS.

This program downloads a Google Cloud service account public certificate, extracts the public key, and verifies an RS256 (RSA + SHA256) signature. The signature is read from a JSON structure written by the matching program `gcp-sign`.

This program duplicates the functionality of openssl:

`openssl dgst -sha256 -verify public_key.pem -signature example.sign example.data`

## Signature file format

```
{
  "private_key_id": "same as service account JSON key file",
  "client_x509_cert_url": "same as service account JSON key file",
  "format": "base64",
  "signature": "encoded binary string"
}
```

`format` can be `base64`, `base64url`, `hex`.

## Usage

`gcp-verify [OPTIONS] filename`

### OPTIONS
| Flag             | Description                 |
|------------------|-----------------------------|
| -h, --help       | Display help text           |
| -v, --version    | Display version information |
| --debug          | Enable Debug Mode           |
| --signature=path | Signature file. If not specified, write to stdout |

### Environment variables
| Name            | Description                 |
|-----------------|-----------------------------|
| MSG_NOCOLOR     | `false` - Enable color in error messages (default) |
| MSG_NOCOLOR     | `true`  - Disable color in error messages |

### Notes

`filename` is the file to generate the signature from. If a filename is not specified, `stdin` is read instead.

## Examples

### Example 1: Read data from `stdin`, read signature from `filename.sig`
 - `cat filename | gcp-verify --signature=filename.sig`

### Example 2: Read data from `filename`, read signature from `filename.sig`
 - `gcp-verify --signature=filename.sig filename`

## Sign

The matching program `gcp-sign` writes the signature file.

The keys `private_key_id` and `client_x609_cert_url` provide the information necessary to download the public X509 certificate that matches the private key.

 - `gcp-sign --signature=filename.sig filename`

The keys `private_key_id` and `client_x609_cert_url` are copies from the same keys in the service account JSON key file. Those fields are used by `gcp-verify` to download the public X509 certificate that matches the private key.

The key `signature` is the base64 encoded RS256 (RSA + SHA256) binary signature.

## Requirements

Requires Visual Studio and Swift installed on the system. The make tool is from Visual Studio.

### Install Visual Studio:

 - Download link: https://visualstudio.microsoft.com/vs/community/

### Install OpenSSL.

#### Windows

Tested with "Win64 OpenSSL v1.1.1s" downloaded from:
 - Download link: https://slproweb.com/download/Win64OpenSSL-1_1_1s.msi

 Tested with "Win64 OpenSSL v3.0.7" downloaded from:
 - Download link: https://slproweb.com/products/Win32OpenSSL.html

Note: Install the package built for developers.

#### Linux

apt-get install openssl libssl-dev

## Configure

### Windows
Modify the Makefile.w64 to specify the OpenSSL installation path for `PATH_OPENSSL`.

### Linux
Modify the Makefile.linux to specify the OpenSSL installation path for `PATH_OPENSSL`.

This program does not require a Google CLoud service account JSON key. The public key is downloaded from Google's website, no API calls to Google Cloud IAM are made.

 - https://cloud.google.com/iam/docs/creating-managing-service-account-keys

## Build

### Windows

Start a Visual Studio x64 Native Tools Command Prompt.

Use the batch script `make.bat` or type:

`nmake /f Makefile.w64`

The C and Swift source files are compiled and the executable `gcp-verify.exe` is placed in the build directory.

### Linux

Use the batch script `make.sh` or type:

`nmake -f Makefile.linux`

The C and Swift source files are compiled and the executable `gcp-verify` is placed in the build directory.

## Tested Environments
 - Windows 10 - Swift version 5.7.1, Visual Studio 2022 x64
 - Ubuntu 22.04 - Swift version 5.7.1, gcc version 11.3.0

## Limitations
 - None

## Known Bugs
 - None
