/*****************************************************************************
* Date Created: 2022-12-14
* Last Update:  2022-12-14
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
#if !os(macOS)
import FoundationNetworking	// This is required for Linux, does not exist on macOS
#endif

extension Data {
    func urlSafeBase64EncodedString() -> String {
        return base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

struct AuthToken: Codable {
	var access_token: String
	var issued: Int
	var expires_in: Int
	var token_type: String
}

struct Header: Encodable {
	var alg: String
	var typ: String
	var kid: String
}

struct Payload: Encodable {
	var iss: String
	var sub: String
	var aud: String
	var iat: Int
	var exp: Int
	var scope: String
}

struct AccessTokenResponse: Codable {
	var access_token: String
	var expires_in: Int
	var token_type: String
}

struct IDTokenResponse: Codable {
	var id_token: String
}

// FIX scopes comma vs space

func create_signed_jwt(service_account_file: String, scopes: String, issued: Int, duration: Int) -> String? {
	guard let jsonKey = getServiceAccountJson(filename: service_account_file) else {
		return nil
	}

	// Google Endpoint for creating OAuth 2.0 Access Tokens from Signed-JWT
	let auth_url = "https://www.googleapis.com/oauth2/v4/token"

	let expires = issued + duration	// duration is in seconds

	let header = Header(
		alg: "RS256",
		typ: "JWT",
		kid: jsonKey.private_key_id)
	

	let payload = Payload(
		iss: jsonKey.client_email,	// Issuer claim
		sub: jsonKey.client_email,	// Issuer claim
		aud: auth_url,			// Audience claim
		iat: issued,			// Issued At claim
		exp: expires,			// Expire time
		scope: scopes)			// Permissions

/*
	let jwt = create_jwt(header: header, payload: payload)
	print(jwt)
*/

	let h = try! JSONEncoder().encode(header)
	let h_b64 = h.urlSafeBase64EncodedString()

	let p = try! JSONEncoder().encode(payload)
	let p_b64 = p.urlSafeBase64EncodedString()

	if arg_debug {
		print("HEADER:")
		print(h_b64)
		print("PAYLOAD:")
		print(p_b64)
	}

	let str = h_b64 + "." + p_b64

	guard let data = str.data(using: .utf8) else {
		return nil
	}

	// The PEM string must use UNIX line endings (LF) and not DOS/Windows (CR-LF)
	// let privateKey = json.private_key
	let privateKey = jsonKey.private_key.replacingOccurrences(of: "\r\n", with: "\n")

	// Signature is 256 bytes for 2048 key
	var signature = Data(count: 256)

	let ret = sign_rsa_sha256_pkey_string(data: data, pkey: privateKey, signature: &signature)

	if ret != 0 {
		ErrorText("ret: \(ret)")
		return nil
	}

	let s_b64 = signature.urlSafeBase64EncodedString()

	if arg_debug {
		print("SIGNATURE:")
		print(s_b64)
	}

	return str + "." + s_b64
}

func exchangeJwtForAccessToken(_ signed_jwt: String) -> AuthToken? {
	let auth_url = "https://www.googleapis.com/oauth2/v4/token"

	let body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=" + signed_jwt

	let response_string = http_post(uri: auth_url, headers: [:], body: body)

	guard let response_string else {
		// ErrorText("Error: No response data")
		return nil
	}

	guard let data = response_string.data(using: .utf8) else {
		print("Error: Cannot process response data")
		return nil
	}

	let decoder = JSONDecoder()

	do {
		let results = try decoder.decode(AccessTokenResponse.self, from: data)

		// print()
		// print("results:")
		// print(results)

		return AuthToken(
				access_token: results.access_token,
				issued: 0,
				expires_in: results.expires_in,
				token_type: results.token_type)
	} catch {
		// Was an ID Token returned
		// This scopes causes an ID Token to be returned
		// "https://www.googleapis.com/auth/devstorage.read"

		do {
			let _ = try decoder.decode(IDTokenResponse.self, from: data)

			ErrorText("Error: An ID Token was generated instead of an Access Token")

			print(String(data: data, encoding: .utf8)!)
			return nil
		} catch {
			ErrorText(error.localizedDescription)
			return nil
		}
	}
}
