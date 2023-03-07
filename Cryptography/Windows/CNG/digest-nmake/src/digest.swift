/*****************************************************************************
* Date Created: 2022-12-23
* Last Update:  2023-02-10
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

class CngAlgorithmIds {
	let BCRYPT_MD5_ALGORITHM = UnsafeMutablePointer<UInt16>.allocate(capacity: 8)
	let BCRYPT_SHA1_ALGORITHM = UnsafeMutablePointer<UInt16>.allocate(capacity: 8)
	let BCRYPT_SHA256_ALGORITHM = UnsafeMutablePointer<UInt16>.allocate(capacity: 8)
	let BCRYPT_SHA384_ALGORITHM = UnsafeMutablePointer<UInt16>.allocate(capacity: 8)
	let BCRYPT_SHA512_ALGORITHM = UnsafeMutablePointer<UInt16>.allocate(capacity: 8)

	let BCRYPT_OBJECT_LENGTH = UnsafeMutablePointer<UInt16>.allocate(capacity: 16)
	let BCRYPT_HASH_LENGTH = UnsafeMutablePointer<UInt16>.allocate(capacity: 24)

	let MS_PRIMITIVE_PROVIDER = UnsafeMutablePointer<UInt16>.allocate(capacity: 48)
	let MS_PLATFORM_CRYPTO_PROVIDER = UnsafeMutablePointer<UInt16>.allocate(capacity: 48)

	init() {
		copyWideChars(source: "MD5", destination: BCRYPT_MD5_ALGORITHM)
		copyWideChars(source: "SHA1", destination: BCRYPT_SHA1_ALGORITHM)
		copyWideChars(source: "SHA256", destination: BCRYPT_SHA256_ALGORITHM)
		copyWideChars(source: "SHA384", destination: BCRYPT_SHA384_ALGORITHM)
		copyWideChars(source: "SHA512", destination: BCRYPT_SHA512_ALGORITHM)

		copyWideChars(source: "ObjectLength", destination: BCRYPT_OBJECT_LENGTH)
		copyWideChars(source: "HashDigestLength", destination: BCRYPT_HASH_LENGTH)

		copyWideChars(source: "Microsoft Primitive Provider", destination: MS_PRIMITIVE_PROVIDER)
		copyWideChars(source: "Microsoft Platform Crypto Provider", destination: MS_PLATFORM_CRYPTO_PROVIDER)
	}

	deinit {
		BCRYPT_MD5_ALGORITHM.deallocate()
		BCRYPT_SHA1_ALGORITHM.deallocate()
		BCRYPT_SHA256_ALGORITHM.deallocate()
		BCRYPT_SHA384_ALGORITHM.deallocate()
		BCRYPT_SHA512_ALGORITHM.deallocate()

		BCRYPT_OBJECT_LENGTH.deallocate()
		BCRYPT_HASH_LENGTH.deallocate()

		MS_PRIMITIVE_PROVIDER.deallocate()
		MS_PLATFORM_CRYPTO_PROVIDER.deallocate()
	}
}

public class Digest {
	//****************************************
	//
	//****************************************

	var hAlg = BCRYPT_ALG_HANDLE(bitPattern: 0)
	var hHash = BCRYPT_HASH_HANDLE(bitPattern: 0)
	var pbHashObject: LPVOID?
	var pbHash: LPVOID?
	var cbHash: UInt32 = 0

	//****************************************
	//
	//****************************************

	public enum Algorithm {
		case md5
		case sha1
		case sha256
		case sha384
		case sha512
	}

	//****************************************
	//
	//****************************************

	// public init(using algorithm: Algorithm = .sha256) {
	public init(using algorithm: Algorithm) throws {
		let algids = CngAlgorithmIds()
		var alg = algids.BCRYPT_SHA256_ALGORITHM

		let nilptr = UnsafeMutablePointer<UInt8>(bitPattern: 0)
		let nilptr16 = UnsafePointer<UInt16>(bitPattern: 0)

		switch(algorithm) {
			case .md5:
				alg = algids.BCRYPT_MD5_ALGORITHM
			case .sha1:
				alg = algids.BCRYPT_SHA1_ALGORITHM
			case .sha256:
				alg = algids.BCRYPT_SHA256_ALGORITHM
			case .sha384:
				alg = algids.BCRYPT_SHA384_ALGORITHM
			case .sha512:
				alg = algids.BCRYPT_SHA512_ALGORITHM
		}

		// Available providers
		// algids.MS_PRIMITIVE_PROVIDER		"Microsoft Primitive Provider"
		// algids.MS_PLATFORM_CRYPTO_PROVIDER	"Microsoft Platform Crypto Provider"

		let provider = nilptr16
		// let provider = algids.MS_PRIMITIVE_PROVIDER
		// let provider = algids.MS_PLATFORM_CRYPTO_PROVIDER

		var status = BCryptOpenAlgorithmProvider(
						&hAlg,		// [out] NCG provider handle
						alg,		// requested cryptographic algorithm
						provider,	// provider implementation
						0)		// Flags

		if !NT_SUCCESS(status) {
			throw Error(code: status, reason: "Error: BCryptOpenAlgorithmProvider failed")
		}

		//****************************************
		//
		//****************************************

		var cbData: UInt32 = 0
		var cbHashObject: UInt32 = 0

		status = BCryptGetProperty(
						hAlg, 
						algids.BCRYPT_OBJECT_LENGTH, 
						&cbHashObject, 
						4,			// sizeof(DWORD), 
						&cbData, 
						0)

		if !NT_SUCCESS(status) {
			throw Error(code: status, reason: "Error: BCryptGetProperty failed")
		}

		pbHashObject = HeapAlloc(GetProcessHeap(), 0, UInt64(cbHashObject))

		//****************************************
		//
		//****************************************

		cbHash = 0
		cbData = 0

		status = BCryptGetProperty(
						hAlg, 
						algids.BCRYPT_HASH_LENGTH, 
						&cbHash, 
						4,			// sizeof(DWORD), 
						&cbData, 
						0)

		if !NT_SUCCESS(status) {
			throw Error(code: status, reason: "Error: BCryptGetProperty failed")
		}

		pbHash = HeapAlloc(GetProcessHeap(), 0, UInt64(cbHash))

		//****************************************
		//
		//****************************************

		status = BCryptCreateHash(
						hAlg, 
						&hHash, 
						pbHashObject, 
						cbHashObject, 
						nilptr, 	// secret
						0, 		// size of secret
						0)		// flags

		if !NT_SUCCESS(status) {
			throw Error(code: status, reason: "Error: BCryptCreateHash failed")
		}
	}

	//****************************************
	//
	//****************************************

	deinit {
		HeapFree(GetProcessHeap(), 0, pbHash)
		HeapFree(GetProcessHeap(), 0, pbHashObject)
		BCryptDestroyHash(hHash)
		BCryptCloseAlgorithmProvider(hAlg, 0)
	}

	//****************************************
	//
	//****************************************

	public func digestLength() -> Int {
		return Int(cbHash)
	}

	//****************************************
	//
	//****************************************

	public func update(data: Data) throws -> Self {
		var status = Int32(0)

		data.withUnsafeBytes { (ptr) in
			let bytes = ptr.bindMemory(to: UInt8.self).baseAddress!

			status = BCryptHashData(
						hHash,			// handle to hash object
						PBYTE(mutating: bytes),	// data to hash
						UInt32(ptr.count),	// byte count
						0)			// flags
		}

		if !NT_SUCCESS(status) {
			throw Error(code: status, reason: "Error: BCryptHashData failed")
		}

		return self
	}

	//****************************************
	//
	//****************************************

	public func update(ptr: UnsafePointer<UInt8>, count: UInt32) throws -> Self {
		let status = BCryptHashData(
					hHash,			// handle to hash object
					PBYTE(mutating: ptr),	// data to hash
					count,			// byte count
					0)			// flags

		if !NT_SUCCESS(status) {
			throw Error(code: status, reason: "Error: BCryptHashData failed")
		}

		return self
	}

	//****************************************
	//
	//****************************************

	public func update(ptr: UnsafeMutablePointer<UInt8>, count: UInt32) throws -> Self {
		let status = BCryptHashData(
					hHash,			// handle to hash object
					ptr,			// data to hash
					count,			// byte count
					0)			// flags

		if !NT_SUCCESS(status) {
			throw Error(code: status, reason: "Error: BCryptHashData failed")
		}

		return self
	}

	//****************************************
	//
	//****************************************

	public func final() throws -> Data {
		guard let pbHash else {
			throw Error(code: -1, reason: "Error: pbHash is nil")
		}

		let status = BCryptFinishHash(
						hHash, 
						pbHash, 
						cbHash, 
						0)

		if !NT_SUCCESS(status) {
			throw Error(code: status, reason: "Error: BCryptFinishHash failed")
		}

		//****************************************
		//
		//****************************************

		return Data(bytes: pbHash, count: Int(cbHash))
	}

	//****************************************
	//
	//****************************************

	public struct Error: Swift.Error, CustomStringConvertible {
		var errorCode: Int32
		var errorReason: String?
		var errorMsg = ""

		public var description: String {
			let reason: String = self.errorReason ?? "Reason: Unavailable"
			return "Error code: \(self.errorCode) (\(String(format: "0x%x", self.errorCode))), \(reason). \(errorMsg)"
		}

		public init(code: Int32, reason: String?) {
			self.errorCode = code
			self.errorReason = reason

			if code == -1 {
				return
			}

			if let cstr = Win32FormatMessage(code) {
				self.errorMsg = String(cString: cstr)
				Win32FreeMessage(cstr)
			}
		}
	}
}
