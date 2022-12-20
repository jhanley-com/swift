/*****************************************************************************
* Date Created: 2022-12-12
* Last Update:  2022-12-18
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

#include "string.h"
#include "c-interface.h"

#if defined(OS_WINDOWS)
#pragma comment(lib, "libcrypto64MD.lib")
#pragma comment(lib, "libssl64MD.lib")
#endif

typedef unsigned char byte;

// Internal functions
int _sign_rsa_sha256(const byte *msg, size_t mlen, EVP_PKEY *pkey, byte *sig, size_t *slen);
void _print_it(const char *label, const byte *buff, size_t len);

void openssl_init(void)
{
	OpenSSL_add_all_algorithms();
	// Not needed from 1.1.0 onwards
	// ERR_load_BIO_strings();
	ERR_load_crypto_strings();
}

/* SAVE
BIO		*outbio;

	outbio = BIO_new_fp(stdout, BIO_NOCLOSE);

	PEM_write_bio_PUBKEY(outbio, public_key);
*/

void malloc_free(const void *ptr)
{
	free((void *)ptr);
}

void openssl_bio_free(const void *ptr)
{
	BIO_free((BIO *)ptr);
}

const char *openssl_get_publickey_from_certificate(const char *certificate)
{
char		*ptr;
size_t		len;
size_t		outlen;
BIO		*bio;
BIO		*bufio;
EVP_PKEY	*public_key;
X509		*cert;

	// printf("cert: %s\n", certificate);

	len = strlen(certificate);

	bufio = BIO_new_mem_buf(certificate, (int)len);

	cert = NULL;
	if (PEM_read_bio_X509(bufio, &cert, 0, NULL) == NULL)
	{
		printf("Failed to load X509 certificate\n");
		printf("%s\n", ERR_error_string(ERR_get_error(), NULL));
		BIO_free(bufio);
		return NULL;
	}

	if ((public_key = X509_get_pubkey(cert)) == NULL)
	{
		printf("Error getting public key from certificate");
		BIO_free(bufio);
		return NULL;
	}

	bio = BIO_new(BIO_s_mem());

	PEM_write_bio_PUBKEY(bio, public_key);

	// printf("%zd\n", BIO_ctrl_pending(bio));

	len = BIO_ctrl_pending(bio) + 1;

	ptr = (char *)malloc(BIO_ctrl_pending(bio) + 1);

	BIO_read_ex(bio, ptr, len, &outlen);

	ptr[len - 1] = 0;

	X509_free(cert);
	BIO_free(bio);

	return ptr;
}

int openssl_sign_rsa_sha256_pkey_string(
	const byte *data,	// Data to be signed
	size_t dlen,		// Data byte length
	const char *pkey,	// Private key (Base64 PEM) memory
	int plen,		// Private key memory byte len
	byte *sig,		// OUT: Signature
	size_t *slen)		// OUT: Signature byte length
{
int		ret;
BIO		*bufio;
EVP_PKEY	*privKey;

	//****************************************
	//
	//****************************************

	SSL_load_error_strings();

	//****************************************
	//
	//****************************************

	if (!data || !sig || !pkey || !plen)
	{
		return -1;
	}

	//****************************************
	//
	//****************************************

	privKey = EVP_PKEY_new();

	bufio = BIO_new_mem_buf(pkey, plen);

	// The PEM string must use UNIX line endings (LF) and not DOS/Windows (CR-LF)

	// if (PEM_read_bio_RSAPrivateKey(bufio, &privKey, 0, NULL) == NULL)
	if (PEM_read_bio_PrivateKey(bufio, &privKey, 0, NULL) == NULL)
	{
		printf("Failed to load private key\n");
		// printf("PEM_read_bio_PrivateKey failed, error 0x%lx\n", ERR_get_error());
		printf("%s\n", ERR_error_string(ERR_get_error(), NULL));
		return -100;
	}

	//****************************************
	//
	//****************************************

	ret = _sign_rsa_sha256(data, dlen, privKey, sig, slen);

	if (ret != 0)
	{
		printf("Failed to create signature, return code %d\n", ret);
		return ret;
	}

	// printf("Created signature\n");
	// printf("slen: %zd\n", *slen);
	// _print_it("Signature", sig, *slen);

	return 0;
}

/*
int openssl_sign_rsa_sha256_pkey_memory(
	const byte *data,	// Data to be signed
	size_t dlen,		// Data byte length
	const char *pkey,	// Private key (Base64 PEM) memory
	int plen,		// Private key memory byte len
	byte **sig,		// OUT: Signature
	size_t *slen)		// OUT: Signature byte length
{
int		ret;
BIO		*bufio;
EVP_PKEY	*privKey;

	// ****************************************
	//
	// ****************************************

	if (!data || !sig || !pkey || !plen)
	{
		return -1;
	}

	// ****************************************
	//
	// ****************************************

	*sig = NULL;
	*slen = 0;

	// ****************************************
	//
	// ****************************************

	privKey = EVP_PKEY_new();

	bufio = BIO_new_mem_buf(pkey, plen);

	// if (PEM_read_bio_RSAPrivateKey(bufio, &privKey, 0, NULL) == NULL)
	if (PEM_read_bio_PrivateKey(bufio, &privKey, 0, NULL) == NULL)
	{
		printf("Failed to load private key\n");
		return -100;
	}

	// ****************************************
	//
	// ****************************************

	ret = _sign_rsa_sha256(data, dlen, privKey, sig, slen);

	if (ret != 0)
	{
		printf("Failed to create signature, return code %d\n", ret);
		return ret;
	}

	// printf("Created signature\n");
	// printf("slen: %zd\n", *slen);
	// _print_it("Signature", *sig, *slen);

	return 0;
}
*/

int openssl_sign_rsa_sha256_pkey_file(
	const byte *data,	// Data to be signed
	size_t dlen,		// Data byte length
	const char *filename,	// Private key (PEM) filename
	byte *sig,		// OUT: Signature
	size_t *slen)		// OUT: Signature byte length
{
EVP_PKEY	*privKey;
FILE		*fp = NULL;

	// ****************************************
	//
	// ****************************************

	if (!data || !sig || !filename)
	{
		return -1;
	}

	// ****************************************
	//
	// ****************************************

#ifdef OS_WINDOWS
int		ret;

	ret = fopen_s(&fp, filename, "r");

	if (ret != 0)
	{
		printf("Failed to open file %s\n", filename);
		return -100;
	}
#else
	fp = fopen(filename, "r");

	if (fp == NULL)
	{
		printf("Failed to open file %s\n", filename);
		return -100;
	}
#endif

	// ****************************************
	//
	// ****************************************

	privKey = EVP_PKEY_new();

	//****************************************
	//
	//****************************************

	if (PEM_read_PrivateKey(fp, &privKey, NULL, NULL) == NULL)
	{
		printf("Failed to load private key\n");
		return -101;
	}

	// ****************************************
	//
	// ****************************************

	fclose(fp);

	// ****************************************
	//
	// ****************************************

	int rc = _sign_rsa_sha256(data, dlen, privKey, sig, slen);

	if (rc != 0)
	{
		printf("Failed to create signature, return code %d\n", rc);
		return rc;
	}

	// printf("Created signature\n");
	// printf("slen: %zd\n", *slen);
	// _print_it("Signature", sig, *slen);

	return 0;
}

int _sign_rsa_sha256(
	const byte *msg,	// Data to be signed
	size_t mlen,		// Data byte length
	EVP_PKEY *pkey,		// RSA Private Key
	byte *sig,		// OUT: Signature
	size_t *slen)		// OUT: Signature byte length
{
byte	*_sig;

	// ****************************************
	//
	// ****************************************

	if (!msg || !pkey)
	{
		return -1;
	}

	// ****************************************
	//
	// ****************************************

	EVP_MD_CTX *ctx = NULL;

	ctx = EVP_MD_CTX_create();

	if (ctx == NULL)
	{
		printf("EVP_MD_CTX_create failed, error 0x%lx\n", ERR_get_error());
		return -2;
	}

	// ****************************************
	//
	// ****************************************

	const EVP_MD *md = EVP_get_digestbyname("SHA256");

	if (md == NULL)
	{
		printf("EVP_get_digestbyname failed, error 0x%lx\n", ERR_get_error());
		EVP_MD_CTX_destroy(ctx);
		return -3;
	}

	// ****************************************
	//
	// ****************************************

	int rc = EVP_DigestInit_ex(ctx, md, NULL);

	if (rc != 1)
	{
		printf("EVP_DigestInit_ex failed, error 0x%lx\n", ERR_get_error());
		EVP_MD_CTX_destroy(ctx);
		return -4;
	}

	// ****************************************
	//
	// ****************************************

	rc = EVP_DigestSignInit(ctx, NULL, md, NULL, pkey);

	if (rc != 1)
	{
		printf("EVP_DigestSignInit failed, error 0x%lx\n", ERR_get_error());
		EVP_MD_CTX_destroy(ctx);
		return -5;
	}

	// ****************************************
	//
	// ****************************************

	rc = EVP_DigestSignUpdate(ctx, msg, mlen);

	if (rc != 1)
	{
		printf("EVP_DigestSignUpdate failed, error 0x%lx\n", ERR_get_error());
		EVP_MD_CTX_destroy(ctx);
		return -6;
	}

	// ****************************************
	//
	// ****************************************

	size_t req = 0;
	rc = EVP_DigestSignFinal(ctx, NULL, &req);

	if (rc != 1)
	{
		printf("EVP_DigestSignFinal failed (1), error 0x%lx\n", ERR_get_error());
		EVP_MD_CTX_destroy(ctx);
		return -7;
	}

	// ****************************************
	//
	// ****************************************

	if (!(req > 0))
	{
		printf("EVP_DigestSignFinal failed (2), error 0x%lx\n", ERR_get_error());
		EVP_MD_CTX_destroy(ctx);
		return -8;
	}

	// ****************************************
	//
	// ****************************************

	_sig = (byte *)OPENSSL_malloc(req);

	if (_sig == NULL)
	{
		printf("OPENSSL_malloc failed, error 0x%lx\n", ERR_get_error());
		EVP_MD_CTX_destroy(ctx);
		return -9;
	}

	// ****************************************
	//
	// ****************************************

	*slen = req;
	rc = EVP_DigestSignFinal(ctx, _sig, slen);

	if (rc != 1)
	{
		printf("EVP_DigestSignFinal failed (3), return code %d, error 0x%lx\n", rc, ERR_get_error());
		EVP_MD_CTX_destroy(ctx);
		return -10;
	}

	// ****************************************
	//
	// ****************************************

	memcpy(sig, _sig, *slen);

	// ****************************************
	//
	// ****************************************

	if (ctx)
	{
		EVP_MD_CTX_destroy(ctx);
		ctx = NULL;
	}

	return 0;
}

void _print_it(const char *label, const byte *buff, size_t len)
{
    if (!buff || !len)
        return;

    if (label)
        printf("%s: ", label);

    for (size_t i = 0; i < len; ++i)
        printf("%02X", buff[i]);

    printf("\n");
}

int openssl_verify_rsa_sha256_pubkey_string(
	const byte *data,	// Data that was signed
	size_t dlen,		// Data byte length
	const char *pkey,	// Public key (Base64 PEM) memory
	int plen,		// Public key memory byte len
	const byte *sig,	// Signature
	size_t slen)		// Signature byte length
{
int		ret;
BIO		*bufio;
EVP_PKEY	*pubKey;

	// ****************************************
	//
	// ****************************************

	SSL_load_error_strings();

	// ****************************************
	//
	// ****************************************

	if (!data || !sig || !pkey || !plen)
	{
		return -1;
	}

	// ****************************************
	//
	// ****************************************

	pubKey = EVP_PKEY_new();

	bufio = BIO_new_mem_buf(pkey, plen);

	// The PEM string must use UNIX line endings (LF) and not DOS/Windows (CR-LF)

	if (PEM_read_bio_PUBKEY(bufio, &pubKey, 0, NULL) == NULL)
	{
		printf("Failed to load public key\n");
		printf("%s\n", ERR_error_string(ERR_get_error(), NULL));
		return -100;
	}

	// ****************************************
	//
	// ****************************************

	EVP_MD_CTX *ctx = NULL;

	ctx = EVP_MD_CTX_create();

	if (ctx == NULL)
	{
		printf("EVP_MD_CTX_create failed, error 0x%lx\n", ERR_get_error());
		return -2;
	}

	// ****************************************
	//
	// ****************************************

	ret = EVP_DigestVerifyInit(ctx, NULL, EVP_sha256(), NULL, pubKey);

	if (ret != 1)
	{
		printf("EVP_DigestVerifyInit failed, error 0x%lx\n", ERR_get_error());
		EVP_MD_CTX_destroy(ctx);
		return -5;
	}

	// ****************************************
	//
	// ****************************************

	ret = EVP_DigestVerifyUpdate(ctx, data, dlen);

	if (ret != 1)
	{
		printf("EVP_DigestVerifyUpdate failed, error 0x%lx\n", ERR_get_error());
		EVP_MD_CTX_destroy(ctx);
		return -6;
	}

	// ****************************************
	//
	// ****************************************

	ret = EVP_DigestVerifyFinal(ctx, sig, slen);

	if (ret != 1)
	{
		// printf("EVP_DigestVerifyFinal failed (1), error 0x%lx\n", ERR_get_error());
		printf("EVP_DigestVerifyFinal failed\n");
		printf("%s\n", ERR_error_string(ERR_get_error(), NULL));
		EVP_MD_CTX_destroy(ctx);
		return -7;
	}

	// ****************************************
	//
	// ****************************************

	return 0;
}
