# GitHub Device Authorization Grant Example

## Release Date
November 29, 2022

## Program License

MIT Licensed. Refer to copyright.txt and LICENSE for details.

## Program Description

This program generates a GitHub token using Device Authorization Grant

Requires a GitHub Client ID and Enable Device Flow.

Set the environment variables prior to running the program:
 - GITHUB_CLIENT_ID=client_id
 - GITHUB_SCOPE=scope

## Reference Documentation

 - [GitHub: Creating an OAuth App](https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app)
 - [GitHub: Device Flow](https://docs.github.com/en/developers/apps/building-oauth-apps/authorizing-oauth-apps#device-flow)
 - [GitHub: Scopes for OAuth Apps](https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps)

## Run

`swift run`

## Build

`swift build -c release`

### Alternate command for Windows

`swiftc src/main.swift src/http.swift src/github_auth.swift src/terminal.swift -o auth-device.exe`

### Alternate command for Linux and macOS

`swiftc src/main.swift src/http.swift src/github_auth.swift src/terminal.swift -o auth-device`

## Usage

`auth-device [OPTIONS]`

### OPTIONS:
| Flag          | Description                 |
|---------------|-----------------------------|
| -h, --help    | Display help text           |
| -v, --version | Display version information |
| --debug       | Enable Debug Mode           |

## Tested Environments
 - Windows 10 - Swift version 5.7.1
 - Ubuntu 20.04 - Swift version 5.7.1
 - macOS Monterey 12.6.1 (Intel) - Swift version 5.7.0

## Limitations
 - None

## Known Bugs
 - None
