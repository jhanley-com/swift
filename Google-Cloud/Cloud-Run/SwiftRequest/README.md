# Google Cloud Run Swift Example

## Release Date
October 24, 2022

## Program License

MIT Licensed. Refer to copyright.txt and LICENSE for details.

## Program Description

This program displays details on the HTTP request, container environment and directory contents for a Swift container deployed to Google Cloud Run.

## Program Source Code

The main program is src\main.swift. This program depends on the [swifter](https://github.com/httpswift/swifter) http server engine written in Swift.

## Setup

Clone the repository to your Windows system. This project will also work on macOS and Linux but the scripts in the tools\windows directory are written for Windows. I plan to port the tools\windows directory to linux and macOS in the future.

Edit the file tools\windows\gcp_build.bat and set the IMAGE_NAME and PROJECT_ID variables.

Edit the file tools\windows\gcp_deploy.bat and set the IMAGE_NAME, PROJECT_ID and REGION variables.

## Build Container

Run the script tools\windows\gcp_build.bat

The Dockerfile is a multi-stage build to reduce container size.

## Deploy Container

Run the script tools\windows\gcp_deploy.bat

## Local Development and Testing

The script tools\windows\run_swift_container.bat runs a container with the Swift development system. The current directory is mounted as a volume. Once the container is started, change to the /swift directory. Then run the program via the command "swift run".

The following scripts build and run the container for local testing in Docker:
 - tools\windows\build_local.bat    - Docker build
 - tools\windows\run_local.bat      - Docker run
 - tools\windows\run_local_bash.bat - Docker run loading the bash shell for debugging
 - tools\windows\stop_local.bat     - Kills the local running container

The script tools\windows\clean.bat deletes the .build directory to remove artifacts.

## Tested Environments
 - Swift version 5.7
 - Ubuntu 22.04 container swift-slim
 - macOS Monterey 12.6

## Failed Environments
 - This program fails to build on Windows

## Known Bugs
None.
