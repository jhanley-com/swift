# Hex File Display Program for macOS

## Release Date
October 4, 2022

## Program License

MIT Licensed. Refer to copyright.txt and LICENSE for details.

## Program Description

This program displays the contents of a file in both hex and ASCII.

![Image](screenshot.png)

## Usage

Build the program either with Xcode or with the Xcode command command line tool xcodebuild.
To build from the command line use the build.sh script.

Example command line build command for Intel architecture:

`xcodebuild -workspace hex-gui.xcodeproj/project.xcworkspace -scheme hex-gui CONFIGURATION_BUILD_DIR=build -configuration Release -arch x86_64`

## Tested Environments
 - Xcode 14.0.1
 - Swift version 5.7
 - macOS Monterey 12.6 Intel

## Known Bugs
None.
