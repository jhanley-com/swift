/*****************************************************************************
* Date Created: 2022-12-23
* Last Update:  2023-01-10
* https://www.jhanley.com
* Copyright (c) 2020, John J. Hanley
* Author: John J. Hanley
* License: MIT
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*****************************************************************************/

import Foundation

func run_tests() -> Int32 {
	InfoText("Running tests:")

	var ret = Int32(0)

	// MD5
	ret |= test_md5_1()		// MD5()
	ret |= test_md5_2()		// MD5("hello world")
	ret |= test_md5_3()		// MD5("hello world") - in two update calls
	ret |= test_md5_4()		// DigestLength
	ret |= test_md5_5()		// Write digest to temp file and verify

	// SHA1
	ret |= test_sha1_1()		// SHA1()
	ret |= test_sha1_2()		// SHA1("hello world")
	ret |= test_sha1_3()		// SHA1("hello world") - in two update calls
	ret |= test_sha1_4()		// DigestLength
	ret |= test_sha1_5()		// Write digest to temp file and verify

	// SHA256
	ret |= test_sha256_1()		// SHA256()
	ret |= test_sha256_2()		// SHA256("hello world")
	ret |= test_sha256_3()		// SHA256("hello world") - in two update calls
	ret |= test_sha256_4()		// DigestLength
	ret |= test_sha256_5()		// Write binary digest to temp file and verify
	ret |= test_sha256_6()		// Write hex digest to temp file and verify
	ret |= test_sha256_7()		// Write base64 digest to temp file and verify
	ret |= test_sha256_8()		// Write base64url digest to temp file and verify
	ret |= test_sha256_9()		// Verify against OpenSSL with data
	ret |= test_sha256_10()		// Verify against OpenSSL with data
	ret |= test_sha256_11()		// Verify against OpenSSL with data
	ret |= test_sha256_12()		// Verify against OpenSSL with data

	// SHA384
	ret |= test_sha384_1()		// SHA384()
	ret |= test_sha384_2()		// SHA384("hello world")
	ret |= test_sha384_3()		// SHA384("hello world") - in two update calls
	ret |= test_sha384_4()		// DigestLength
	ret |= test_sha384_5()		// Write digest to temp file and verify
	ret |= test_sha384_9()		// Verify against OpenSSL with data

	// SHA512
	ret |= test_sha512_1()		// SHA512()
	ret |= test_sha512_2()		// SHA512("hello world")
	ret |= test_sha512_3()		// SHA512("hello world") - in two update calls
	ret |= test_sha512_4()		// DigestLength
	ret |= test_sha512_5()		// Write digest to temp file and verify
	ret |= test_sha512_9()		// Verify against OpenSSL with data

	// ret |= test_sha256_99()

	if ret == 0 {
		InfoText("All tests passed")
	}

	return ret
}

func test_md5_1() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "" | openssl dgst -md5 -r
	//****************************************

	let input = Data()
	let value = "d41d8cd98f00b204e9800998ecf8427e"

	do {
		let result = try Digest(using: .md5).update(data: input).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_md5_1 failure")
			ErrorText("Digest(using: .md5) failed")
			return 1
		}

		InfoText("test_md5_1 success")
		return 0
	}
	catch {
		ErrorText("test_md5_1 failure")
		ErrorText("Digest(using: .md5) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_md5_2() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "hello world" | openssl dgst -md5 -r
	//****************************************

	let input = Data("hello world".utf8)
	let value = "5eb63bbbe01eeed093cb22bb8f5acdc3"

	do {
		let result = try Digest(using: .md5).update(data: input).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_md5_2 failure")
			ErrorText("Digest(using: .md5) failed")
			return 1
		}

		InfoText("test_md5_2 success")
		return 0
	}
	catch {
		ErrorText("test_md5_2 failure")
		ErrorText("Digest(using: .md5) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_md5_3() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "hello world" | openssl dgst -md5 -r
	//****************************************

	let input1 = Data("hello ".utf8)
	let input2 = Data("world".utf8)
	let value = "5eb63bbbe01eeed093cb22bb8f5acdc3"

	do {
		let result = try Digest(using: .md5).update(data: input1).update(data: input2).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_md5_3 failure")
			ErrorText("Digest(using: .md5) failed")
			return 1
		}

		InfoText("test_md5_3 success")
		return 0
	}
	catch {
		ErrorText("test_md5_3 failure")
		ErrorText("Digest(using: .md5) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_md5_4() -> Int32 {
	do {
		let result = try Digest(using: .md5).digestLength()

		if result != 16 {
			ErrorText("test_md5_4 failure")
			ErrorText("Incorrect Digest Length returned")
			return 1
		}

		InfoText("test_md5_4 success")
		return 0
	}
	catch {
		ErrorText("test_md5_4 failure")
		ErrorText("Digest(using: .md5) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_md5_5() -> Int32 {
	// MD5 of 4096 bytes of zeros
	let value = "620f0b67a91f7f74151bc5be745b7110"

	do {
		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file1 = tempDir.appendingPathComponent("digest_" + uuid + ".data")
		let file2 = tempDir.appendingPathComponent("digest_" + uuid + ".out")

		let data = Data(count: 4096)

		let url = URL(fileURLWithPath: file1)
		try data.write(to: url)

		// Setup args for main program
		arg_debug = false
		arg_silent = true
		arg_test = false
		input_file = file1
		output_file = file2
		digest_algorithm = Digest.Algorithm.md5
		digest_format = "binary"

		let ret = processDigestCommand()

		if ret != 0 {
			ErrorText("test_md5_5 failure")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		// Read the created file and verify

		let result = try Data(contentsOf: URL(fileURLWithPath: file2))

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_md5_5 failure")
			ErrorText("Digest(using: .md5) failed")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		InfoText("test_md5_5 success")
		removeFile(file1)
		removeFile(file2)
		return 0
	}
	catch {
		ErrorText("test_md5_5 failure")
		ErrorText("Digest(using: .md5) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha1_1() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "" | openssl dgst -sha1 -r
	//****************************************

	let input = Data()
	let value = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

	do {
		let result = try Digest(using: .sha1).update(data: input).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha1_1 failure")
			ErrorText("Digest(using: .sha1) failed")
			return 1
		}

		InfoText("test_sha1_1 success")
		return 0
	}
	catch {
		ErrorText("test_sha1_1 failure")
		ErrorText("Digest(using: .sha1) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha1_2() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "hello world" | openssl dgst -sha1 -r
	//****************************************

	let input = Data("hello world".utf8)
	let value = "2aae6c35c94fcfb415dbe95f408b9ce91ee846ed"

	do {
		let result = try Digest(using: .sha1).update(data: input).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha1_2 failure")
			ErrorText("Digest(using: .sha1) compare failed")
			return 1
		}

		InfoText("test_sha1_2 success")
		return 0
	}
	catch {
		ErrorText("test_sha1_2 failure")
		ErrorText("Digest(using: .sha1) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha1_3() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "hello world" | openssl dgst -sha1 -r
	//****************************************

	let input1 = Data("hello ".utf8)
	let input2 = Data("world".utf8)
	let value = "2aae6c35c94fcfb415dbe95f408b9ce91ee846ed"

	do {
		let result = try Digest(using: .sha1).update(data: input1).update(data: input2).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha1_3 failure")
			ErrorText("Digest(using: .sha1) compare failed")
			return 1
		}

		InfoText("test_sha1_3 success")
		return 0
	}
	catch {
		ErrorText("test_sha1_3 failure")
		ErrorText("Digest(using: .sha1) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha1_4() -> Int32 {
	do {
		let result = try Digest(using: .sha1).digestLength()

		if result != 20 {
			ErrorText("test_sha1_4 failure")
			ErrorText("Incorrect Digest Length returned")
			return 1
		}

		InfoText("test_sha1_4 success")
		return 0
	}
	catch {
		ErrorText("test_sha1_4 failure")
		ErrorText("Digest(using: .sha1) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha1_5() -> Int32 {
	// SHA1 of 4096 bytes of zeros
	let value = "1ceaf73df40e531df3bfb26b4fb7cd95fb7bff1d"

	do {
		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file1 = tempDir.appendingPathComponent("digest_" + uuid + ".data")
		let file2 = tempDir.appendingPathComponent("digest_" + uuid + ".out")

		let data = Data(count: 4096)

		let url = URL(fileURLWithPath: file1)
		try data.write(to: url)

		// Setup args for main program
		arg_debug = false
		arg_silent = true
		arg_test = false
		input_file = file1
		output_file = file2
		digest_algorithm = Digest.Algorithm.sha1
		digest_format = "binary"

		let ret = processDigestCommand()

		if ret != 0 {
			ErrorText("test_sha1_5 failure")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		// Read the created file and verify

		let result = try Data(contentsOf: URL(fileURLWithPath: file2))

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha1_5 failure")
			ErrorText("Digest(using: .sha1) failed")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		InfoText("test_sha1_5 success")
		removeFile(file1)
		removeFile(file2)
		return 0
	}
	catch {
		ErrorText("test_sha1_5 failure")
		ErrorText("Digest(using: .sha1) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha256_1() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "" | openssl dgst -sha256 -r
	//****************************************

	let input = Data()
	let value = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

	do {
		let result = try Digest(using: .sha256).update(data: input).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha256_1 failure")
			ErrorText("Digest(using: .sha256) failed")
			return 1
		}

		InfoText("test_sha256_1 success")
		return 0
	}
	catch {
		ErrorText("test_sha256_1 failure")
		ErrorText("Digest(using: .sha256) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha256_2() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "hello world" | openssl dgst -sha256 -r
	//****************************************

	let input = Data("hello world".utf8)
	let value = "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"

	do {
		let result = try Digest(using: .sha256).update(data: input).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha256_2 failure")
			ErrorText("Digest(using: .sha256) compare failed")
			return 1
		}

		InfoText("test_sha256_2 success")
		return 0
	}
	catch {
		ErrorText("test_sha256_2 failure")
		ErrorText("Digest(using: .sha256) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha256_3() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "hello world" | openssl dgst -sha256 -r
	//****************************************

	let input1 = Data("hello ".utf8)
	let input2 = Data("world".utf8)
	let value = "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"

	do {
		let result = try Digest(using: .sha256).update(data: input1).update(data: input2).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha256_3 failure")
			ErrorText("Digest(using: .sha256) compare failed")
			return 1
		}

		InfoText("test_sha256_3 success")
		return 0
	}
	catch {
		ErrorText("test_sha256_3 failure")
		ErrorText("Digest(using: .sha256) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha256_4() -> Int32 {
	do {
		let result = try Digest(using: .sha256).digestLength()

		if result != 32 {
			ErrorText("test_sha256_4 failure")
			ErrorText("Incorrect Digest Length returned")
			return 1
		}

		InfoText("test_sha256_4 success")
		return 0
	}
	catch {
		ErrorText("test_sha256_4 failure")
		ErrorText("Digest(using: .sha256) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha256_5() -> Int32 {
	// SHA256 of 4096 bytes of zeros
	let value = "ad7facb2586fc6e966c004d7d1d16b024f5805ff7cb47c7a85dabd8b48892ca7"

	do {
		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file1 = tempDir.appendingPathComponent("digest_" + uuid + ".data")
		let file2 = tempDir.appendingPathComponent("digest_" + uuid + ".out")

		let data = Data(count: 4096)

		let url = URL(fileURLWithPath: file1)
		try data.write(to: url)

		// Setup args for main program
		arg_debug = false
		arg_silent = true
		arg_test = false
		input_file = file1
		output_file = file2
		digest_algorithm = Digest.Algorithm.sha256
		digest_format = "binary"

		let ret = processDigestCommand()

		if ret != 0 {
			ErrorText("test_sha256_5 failure")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		// Read the created file and verify

		let result = try Data(contentsOf: URL(fileURLWithPath: file2))

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha256_5 failure")
			ErrorText("Digest(using: .sha256) failed")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		InfoText("test_sha256_5 success")
		removeFile(file1)
		removeFile(file2)
		return 0
	}
	catch {
		ErrorText("test_sha256_5 failure")
		ErrorText("Digest(using: .sha256) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha256_6() -> Int32 {
	// SHA256 of 4096 bytes of zeros
	let value = "ad7facb2586fc6e966c004d7d1d16b024f5805ff7cb47c7a85dabd8b48892ca7"

	do {
		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file1 = tempDir.appendingPathComponent("digest_" + uuid + ".data")
		let file2 = tempDir.appendingPathComponent("digest_" + uuid + ".out")

		let data = Data(count: 4096)

		let url = URL(fileURLWithPath: file1)
		try data.write(to: url)

		// Setup args for main program
		arg_debug = false
		arg_silent = true
		arg_test = false
		input_file = file1
		output_file = file2
		digest_algorithm = Digest.Algorithm.sha256
		digest_format = "hex"

		let ret = processDigestCommand()

		if ret != 0 {
			ErrorText("test_sha256_6 failure")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		// Read the created file and verify

		let hexstr = try String(contentsOf: URL(fileURLWithPath: file2))

		if value != hexstr {
			ErrorText("test_sha256_6 failure")
			ErrorText("Digest(using: .sha256) failed")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		InfoText("test_sha256_6 success")
		removeFile(file1)
		removeFile(file2)
		return 0
	}
	catch {
		ErrorText("test_sha256_6 failure")
		ErrorText("Digest(using: .sha256) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha256_7() -> Int32 {
	// base64 SHA256 of 4096 bytes of zeros
	let value = "rX+sslhvxulmwATX0dFrAk9YBf98tHx6hdq9i0iJLKc="

	do {
		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file1 = tempDir.appendingPathComponent("digest_" + uuid + ".data")
		let file2 = tempDir.appendingPathComponent("digest_" + uuid + ".out")

		let data = Data(count: 4096)

		let url = URL(fileURLWithPath: file1)
		try data.write(to: url)

		// Setup args for main program
		arg_debug = false
		arg_silent = true
		arg_test = false
		input_file = file1
		output_file = file2
		digest_algorithm = Digest.Algorithm.sha256
		digest_format = "base64"

		let ret = processDigestCommand()

		if ret != 0 {
			ErrorText("test_sha256_7 failure")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		// Read the created file and verify

		let hexstr = try String(contentsOf: URL(fileURLWithPath: file2))

		if value != hexstr {
			ErrorText("test_sha256_7 failure")
			ErrorText("Digest(using: .sha256) failed")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		InfoText("test_sha256_7 success")
		removeFile(file1)
		removeFile(file2)
		return 0
	}
	catch {
		ErrorText("test_sha256_7 failure")
		ErrorText("Digest(using: .sha256) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha256_8() -> Int32 {
	// base64url SHA256 of 4096 bytes of zeros
	let value = "rX-sslhvxulmwATX0dFrAk9YBf98tHx6hdq9i0iJLKc"

	do {
		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file1 = tempDir.appendingPathComponent("digest_" + uuid + ".data")
		let file2 = tempDir.appendingPathComponent("digest_" + uuid + ".out")

		let data = Data(count: 4096)

		let url = URL(fileURLWithPath: file1)
		try data.write(to: url)

		// Setup args for main program
		arg_debug = false
		arg_silent = true
		arg_test = false
		input_file = file1
		output_file = file2
		digest_algorithm = Digest.Algorithm.sha256
		digest_format = "base64url"

		let ret = processDigestCommand()

		if ret != 0 {
			ErrorText("test_sha256_8 failure")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		// Read the created file and verify

		let hexstr = try String(contentsOf: URL(fileURLWithPath: file2))

		if value != hexstr {
			ErrorText("test_sha256_8 failure")
			ErrorText("Digest(using: .sha256) failed")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		InfoText("test_sha256_8 success")
		removeFile(file1)
		removeFile(file2)
		return 0
	}
	catch {
		ErrorText("test_sha256_8 failure")
		ErrorText("Digest(using: .sha256) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha256_9() -> Int32 {
	do {
		//****************************************
		// Create a data file with 49 KB of 0xab
		//****************************************

		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file = tempDir.appendingPathComponent("digest_" + uuid + ".data")

		let count = 49 * 1024
		var data = Data(count: count)

		for x in 0..<count {
			data[x] = 0xab
		}

		let url = URL(fileURLWithPath: file)
		try data.write(to: url)

		//****************************************
		// Calculate digest
		//****************************************

		let result = try Digest(using: .sha256).update(data: data).final()

		let hexstr = result.hexEncodedString()

		//****************************************
		// Execute OpenSSL to calculate the digest
		//****************************************

		let program = "openssl.exe"
		let args = ["dgst", "-sha256", "-r", file]

		let (code, str) = execProgram(programName: program, args: args)

		if code != 0 {
			ErrorText("test_sha256_9 failure")
			ErrorText("execProgram returned code: \(code)")
			removeFile(file)
			return 1
		}

		let digest = str.split(separator: " *")[0]

		//****************************************
		// Compare results
		//****************************************

		if digest != hexstr {
			ErrorText("test_sha256_9 failure")
			ErrorText("Digest(using: .sha256) failed")
			removeFile(file)
			return 1
		}

		InfoText("test_sha256_9 success")
		removeFile(file)
		return 0
	}
	catch {
		ErrorText("test_sha256_9 failure")
		ErrorText("Digest(using: .sha256) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha256_10() -> Int32 {
	do {
		//****************************************
		// Create a data file with 1 MB of data
		// Each 4 KB block is initialized with
		// different data. The digest is updated
		// with multiple calls.
		//****************************************

		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file = tempDir.appendingPathComponent("digest_" + uuid + ".data")

		FileManager.default.createFile(atPath: file, contents: nil)

		let fh = FileHandle(forWritingAtPath: file)

		guard let fh else {
			ErrorText("test_sha256_10 failure")
			ErrorText("Error: Cannot create file")
			return Int32(-1)
		}

		let d = try Digest(using: digest_algorithm)

		let count = 4096
		var data = Data(count: count)

		for x in 0..<256 {
			for y in 0..<count {
				data[y] = UInt8(x)
			}

			try fh.write(contentsOf: data)

			let _ = try d.update(data: data)
		}

		try fh.close()

		//****************************************
		// Calculate digest
		//****************************************

		let result = try d.final()

		let hexstr = result.hexEncodedString()

		//****************************************
		// Execute OpenSSL to calculate the digest
		//****************************************

		let program = "openssl.exe"
		let args = ["dgst", "-sha256", "-r", file]

		let (code, str) = execProgram(programName: program, args: args)

		if code != 0 {
			ErrorText("test_sha256_10 failure")
			ErrorText("execProgram returned code: \(code)")
			removeFile(file)
			return 1
		}

		let digest = str.split(separator: " *")[0]

		//****************************************
		// Compare results
		//****************************************

		if digest != hexstr {
			ErrorText("test_sha256_10 failure")
			ErrorText("Digest(using: .sha256) failed")
			removeFile(file)
			return 1
		}

		InfoText("test_sha256_10 success")
		removeFile(file)
		return 0
	}
	catch {
		ErrorText("test_sha256_10 failure")
		ErrorText("Digest(using: .sha256) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha256_11() -> Int32 {
	// SHA256 of 4096 bytes of zeros comparing output with OpenSSL

	do {
		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file1 = tempDir.appendingPathComponent("digest_" + uuid + ".data")
		let file2 = tempDir.appendingPathComponent("digest_" + uuid + ".out")

		let data = Data(count: 4096)

		let url = URL(fileURLWithPath: file1)
		try data.write(to: url)

		// Setup args for main program
		arg_debug = false
		arg_silent = true
		arg_test = false
		arg_openssl = true
		arg_coreutils = false
		input_file = file1
		output_file = file2
		digest_algorithm = Digest.Algorithm.sha256
		digest_format = "hex"

		let ret = processDigestCommand()

		if ret != 0 {
			ErrorText("test_sha256_11 failure")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		// Read the created file and verify

		let hexstr = try String(contentsOf: URL(fileURLWithPath: file2))

		//****************************************
		// Execute OpenSSL to calculate the digest
		//****************************************

		let program = "openssl.exe"
		let args = ["dgst", "-sha256", file1]

		let (code, str) = execProgram(programName: program, args: args)

		if code != 0 {
			ErrorText("test_sha512_11 failure")
			ErrorText("execProgram returned code: \(code)")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		let digest = removeTrailingNL(string: str)

		if digest != hexstr {
			ErrorText("test_sha256_11 failure")
			ErrorText("Digest(using: .sha256) failed")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		InfoText("test_sha256_11 success")
		removeFile(file1)
		removeFile(file2)
		return 0
	}
	catch {
		ErrorText("test_sha256_11 failure")
		ErrorText("Digest(using: .sha256) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha256_12() -> Int32 {
	// SHA256 of 4096 bytes of zeros comparing output with OpenSSL

	do {
		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file1 = tempDir.appendingPathComponent("digest_" + uuid + ".data")
		let file2 = tempDir.appendingPathComponent("digest_" + uuid + ".out")

		let data = Data(count: 4096)

		let url = URL(fileURLWithPath: file1)
		try data.write(to: url)

		// Setup args for main program
		arg_debug = false
		arg_silent = true
		arg_test = false
		arg_openssl = false
		arg_coreutils = true
		input_file = file1
		output_file = file2
		digest_algorithm = Digest.Algorithm.sha256
		digest_format = "hex"

		let ret = processDigestCommand()

		if ret != 0 {
			ErrorText("test_sha256_12 failure")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		// Read the created file and verify

		let hexstr = try String(contentsOf: URL(fileURLWithPath: file2))

		//****************************************
		// Execute OpenSSL to calculate the digest
		//****************************************

		let program = "openssl.exe"
		let args = ["dgst", "-sha256", "-r", file1]

		let (code, str) = execProgram(programName: program, args: args)

		if code != 0 {
			ErrorText("test_sha512_11 failure")
			ErrorText("execProgram returned code: \(code)")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		let digest = removeTrailingNL(string: str)

		if digest != hexstr {
			ErrorText("test_sha256_12 failure")
			ErrorText("Digest(using: .sha256) failed")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		InfoText("test_sha256_12 success")
		removeFile(file1)
		removeFile(file2)
		return 0
	}
	catch {
		ErrorText("test_sha256_12 failure")
		ErrorText("Digest(using: .sha256) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha384_1() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "" | openssl dgst -sha384 -r
	//****************************************

	let input = Data()
	let value = "38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b"

	do {
		let result = try Digest(using: .sha384).update(data: input).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha384_1 failure")
			ErrorText("Digest(using: .sha384) compare failed")
			return 1
		}

		InfoText("test_sha384_1 success")
		return 0
	}
	catch {
		ErrorText("test_sha384_1 failure")
		ErrorText("Digest(using: .sha384) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha384_2() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "hello world" | openssl dgst -sha384 -r
	//****************************************

	let input = Data("hello world".utf8)
	let value = "fdbd8e75a67f29f701a4e040385e2e23986303ea10239211af907fcbb83578b3e417cb71ce646efd0819dd8c088de1bd"

	do {
		let result = try Digest(using: .sha384).update(data: input).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha384_2 failure")
			ErrorText("Digest(using: .sha384) compare failed")
			return 1
		}

		InfoText("test_sha384_2 success")
		return 0
	}
	catch {
		ErrorText("test_sha384_2 failure")
		ErrorText("Digest(using: .sha384) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha384_3() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "hello world" | openssl dgst -sha384 -r
	//****************************************

	let input1 = Data("hello ".utf8)
	let input2 = Data("world".utf8)
	let value = "fdbd8e75a67f29f701a4e040385e2e23986303ea10239211af907fcbb83578b3e417cb71ce646efd0819dd8c088de1bd"

	do {
		let result = try Digest(using: .sha384).update(data: input1).update(data: input2).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha384_3 failure")
			ErrorText("Digest(using: .sha384) compare failed")
			return 1
		}

		InfoText("test_sha384_3 success")
		return 0
	}
	catch {
		ErrorText("test_sha384_3 failure")
		ErrorText("Digest(using: .sha384) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha384_4() -> Int32 {
	do {
		let result = try Digest(using: .sha384).digestLength()

		if result != 48 {
			ErrorText("test_sha384_4 failure")
			ErrorText("Incorrect Digest Length returned")
			return 1
		}

		InfoText("test_sha384_4 success")
		return 0
	}
	catch {
		ErrorText("test_sha384_4 failure")
		ErrorText("Digest(using: .sha384) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha384_5() -> Int32 {
	// SHA384 of 4096 bytes of zeros
	let value = "c0e59a3e3ffbd3b5c75428fb36432facabc745944296ff515f737c4fef4efc64586809f7a16f56354a1eaecf2aa8d774"

	do {
		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file1 = tempDir.appendingPathComponent("digest_" + uuid + ".data")
		let file2 = tempDir.appendingPathComponent("digest_" + uuid + ".out")

		let data = Data(count: 4096)

		let url = URL(fileURLWithPath: file1)
		try data.write(to: url)

		// Setup args for main program
		arg_debug = false
		arg_silent = true
		arg_test = false
		input_file = file1
		output_file = file2
		digest_algorithm = Digest.Algorithm.sha384
		digest_format = "binary"

		let ret = processDigestCommand()

		if ret != 0 {
			ErrorText("test_sha384_5 failure")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		// Read the created file and verify

		let result = try Data(contentsOf: URL(fileURLWithPath: file2))

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha384_5 failure")
			ErrorText("Digest(using: .sha384) failed")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		InfoText("test_sha384_5 success")
		removeFile(file1)
		removeFile(file2)
		return 0
	}
	catch {
		ErrorText("test_sha384_5 failure")
		ErrorText("Digest(using: .sha384) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha384_9() -> Int32 {
	do {
		//****************************************
		// Create a data file with 49 KB of 0xab
		//****************************************

		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file = tempDir.appendingPathComponent("digest_" + uuid + ".data")

		let count = 49 * 1024
		var data = Data(count: count)

		for x in 0..<count {
			data[x] = 0xab
		}

		let url = URL(fileURLWithPath: file)
		try data.write(to: url)

		//****************************************
		// Calculate digest
		//****************************************

		let result = try Digest(using: .sha384).update(data: data).final()

		let hexstr = result.hexEncodedString()

		//****************************************
		// Execute OpenSSL to calculate the digest
		//****************************************

		let program = "openssl.exe"
		let args = ["dgst", "-sha384", "-r", file]

		let (code, str) = execProgram(programName: program, args: args)

		if code != 0 {
			ErrorText("test_sha384_9 failure")
			ErrorText("execProgram returned code: \(code)")
			removeFile(file)
			return 1
		}

		let digest = str.split(separator: " *")[0]

		//****************************************
		// Compare results
		//****************************************

		if digest != hexstr {
			ErrorText("test_sha384_9 failure")
			ErrorText("Digest(using: .sha384) failed")
			removeFile(file)
			return 1
		}

		InfoText("test_sha384_9 success")
		removeFile(file)
		return 0
	}
	catch {
		ErrorText("test_sha384_9 failure")
		ErrorText("Digest(using: .sha384) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha512_1() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "" | openssl dgst -sha512 -r
	//****************************************

	let input = Data()
	let value = "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"

	do {
		let result = try Digest(using: .sha512).update(data: input).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha512_1 failure")
			ErrorText("Digest(using: .sha512) compare failed")
			return 1
		}

		InfoText("test_sha512_1 success")
		return 0
	}
	catch {
		ErrorText("test_sha512_1 failure")
		ErrorText("Digest(using: .sha512) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha512_2() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "hello world" | openssl dgst -sha512 -r
	//****************************************

	let input = Data("hello world".utf8)
	let value = "309ecc489c12d6eb4cc40f50c902f2b4d0ed77ee511a7c7a9bcd3ca86d4cd86f989dd35bc5ff499670da34255b45b0cfd830e81f605dcf7dc5542e93ae9cd76f"

	do {
		let result = try Digest(using: .sha512).update(data: input).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha512_2 failure")
			ErrorText("Digest(using: .sha512) compare failed")
			return 1
		}

		InfoText("test_sha512_2 success")
		return 0
	}
	catch {
		ErrorText("test_sha512_2 failure")
		ErrorText("Digest(using: .sha512) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha512_3() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "hello world" | openssl dgst -sha512 -r
	//****************************************

	let input1 = Data("hello ".utf8)
	let input2 = Data("world".utf8)
	let value = "309ecc489c12d6eb4cc40f50c902f2b4d0ed77ee511a7c7a9bcd3ca86d4cd86f989dd35bc5ff499670da34255b45b0cfd830e81f605dcf7dc5542e93ae9cd76f"

	do {
		let result = try Digest(using: .sha512).update(data: input1).update(data: input2).final()

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha512_3 failure")
			ErrorText("Digest(using: .sha512) compare failed")
			return 1
		}

		InfoText("test_sha512_3 success")
		return 0
	}
	catch {
		ErrorText("test_sha512_3 failure")
		ErrorText("Digest(using: .sha512) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha512_4() -> Int32 {
	do {
		let result = try Digest(using: .sha512).digestLength()

		if result != 64 {
			ErrorText("test_sha512_4 failure")
			ErrorText("Incorrect Digest Length returned")
			return 1
		}

		InfoText("test_sha512_4 success")
		return 0
	}
	catch {
		ErrorText("test_sha512_4 failure")
		ErrorText("Digest(using: .sha512) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha512_5() -> Int32 {
	// SHA512 of 4096 bytes of zeros
	let value = "2d23913d3759ef01704a86b4bee3ac8a29002313ecc98a7424425a78170f219577822fd77e4ae96313547696ad7d5949b58e12d5063ef2ee063b595740a3a12d"

	do {
		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file1 = tempDir.appendingPathComponent("digest_" + uuid + ".data")
		let file2 = tempDir.appendingPathComponent("digest_" + uuid + ".out")

		let data = Data(count: 4096)

		let url = URL(fileURLWithPath: file1)
		try data.write(to: url)

		// Setup args for main program
		arg_debug = false
		arg_silent = true
		arg_test = false
		input_file = file1
		output_file = file2
		digest_algorithm = Digest.Algorithm.sha512
		digest_format = "binary"

		let ret = processDigestCommand()

		if ret != 0 {
			ErrorText("test_sha512_5 failure")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		// Read the created file and verify

		let result = try Data(contentsOf: URL(fileURLWithPath: file2))

		let hexstr = result.hexEncodedString()

		if value != hexstr {
			ErrorText("test_sha512_5 failure")
			ErrorText("Digest(using: .sha512) failed")
			removeFile(file1)
			removeFile(file2)
			return 1
		}

		InfoText("test_sha512_5 success")
		removeFile(file1)
		removeFile(file2)
		return 0
	}
	catch {
		ErrorText("test_sha512_5 failure")
		ErrorText("Digest(using: .sha512) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha512_9() -> Int32 {
	do {
		//****************************************
		// Create a data file with 49 KB of 0xab
		//****************************************

		let tempDir = NSTemporaryDirectory()
		let uuid = UUID().uuidString

		let file = tempDir.appendingPathComponent("digest_" + uuid + ".data")

		let count = 49 * 1024
		var data = Data(count: count)

		for x in 0..<count {
			data[x] = 0xab
		}

		let url = URL(fileURLWithPath: file)
		try data.write(to: url)

		//****************************************
		// Calculate digest
		//****************************************

		let result = try Digest(using: .sha512).update(data: data).final()

		let hexstr = result.hexEncodedString()

		//****************************************
		// Execute OpenSSL to calculate the digest
		//****************************************

		let program = "openssl.exe"
		let args = ["dgst", "-sha512", "-r", file]

		let (code, str) = execProgram(programName: program, args: args)

		if code != 0 {
			ErrorText("test_sha512_9 failure")
			ErrorText("execProgram returned code: \(code)")
			removeFile(file)
			return 1
		}

		let digest = str.split(separator: " *")[0]

		//****************************************
		// Compare results
		//****************************************

		if digest != hexstr {
			ErrorText("test_sha512_9 failure")
			ErrorText("Digest(using: .sha512) failed")
			removeFile(file)
			return 1
		}

		InfoText("test_sha512_9 success")
		removeFile(file)
		return 0
	}
	catch {
		ErrorText("test_sha512_9 failure")
		ErrorText("Digest(using: .sha512) failed")
		ErrorText("\(error)")
		return 1
	}
}

func test_sha256_99() -> Int32 {
	//****************************************
	// OpenSSL command equivelent
	// "C:\Program Files\Git\usr\bin\echo" -n "hello world" | openssl dgst -sha256 -r
	//****************************************

	let input = Data("hello world".utf8)
	// let value = "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"

	print("Start 100,000 calls")
	print("\(Date())")
	for _ in 0..<100000 {
		do {
			let _ = try Digest(using: .sha256).update(data: input).final()
		}
		catch {
			ErrorText("test_sha256_99 failure")
			ErrorText("Digest(using: .sha256) failed")
			ErrorText("\(error)")
			return 1
		}
	}
	print("\(Date())")

	InfoText("test_sha256_99 success")
	return 0
}
