# To Do List

1. Create a Swift Package for just the Digest class.
1. Write tests for base64 and base64url.
1. Look into the Package Manager method of creating a main class.
1. Look into how to create and import a DLL.
1. Try to rewrite Win32FormatMessage() into a native Swift function.
1. Write an equivalent program that integrates with OpenSSL.
1. The OpenSSL CLI is twice as fast as my code

# Completed
1. Rename program to digest.exe and support all digest formats.
1. Rename "hash" to "digest".
1. Create a class interface named Digest.
1. Add CNG Digest support for md5, sha1, sha384, sha512.
1. Break main() into two parts to facilitate testing.
1. Writes tests for the other digest algorithms.
1. Read files in chunks.
1. Add more tests.
   - Create large Data blocks with all zeros, all ones, etc.
1. Add code to run openssl and capture output. Then compare results with internal tests.
1. Add Windows Installer.
1. Move win32 functions to a utility source file (utils.swift).
1. Add command line flag to emulate OpenSSL output.
1. Add command line flag to emulate OpenSSL coreutils output.
1. Add hexstr() to Data() so that the Digest() calls go directly to a hex string.
1. Create a Swift Package Manager package.
