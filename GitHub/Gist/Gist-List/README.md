# List GitHub Gists

## Release Date
November 27, 2022

## Program License

MIT Licensed. Refer to copyright.txt and LICENSE for details.

## Program Description

List GitHub Gists

This program duplicates the GitHub CLI command:

`gh gist list

## Authorization

Create a GitHub Personal Acess Token. Assign the toke to the environment variable GITHUB_TOKEN

## Build

swift build -c release

### Alternate command for Windows

swiftc src/main.swift src/gist.swift src/http.swift -o gist-list.exe

### Alternate command for Linux and macOS

swiftc src/main.swift src/gist.swift src/http.swift -o gist-list

## Usage

gist-list [OPTIONS]"

## Tested Environments
 - Windows 10 - Swift version 5.7.1
 - Ubuntu 20.04 - Swift version 5.7.1
 - macOS Monterey 12.6.1 (Intel) - Swift version 5.7.0

## Limitations
 - Does not support the --secret flag to show only secret gists

## Known Bugs
 - Incorrect Pagination Code in the function gist_list(). See comments in function.
