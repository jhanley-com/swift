#ifndef OpenSSLShim_h
#define OpenSSLShim_h
#include <openssl/conf.h>
#include <openssl/evp.h>
#include <openssl/err.h>
#include <openssl/bio.h>
#include <openssl/x509.h>
#include <openssl/cms.h>
#include <openssl/ssl.h>

#undef SSL_library_init
static inline void SSL_library_init() {
    OPENSSL_init_ssl(0, NULL);
}

#undef SSL_load_error_strings
static inline void SSL_load_error_strings() {
    OPENSSL_init_ssl(OPENSSL_INIT_LOAD_SSL_STRINGS \
                     | OPENSSL_INIT_LOAD_CRYPTO_STRINGS, NULL);
}

#undef OpenSSL_add_all_ciphers
static inline void OpenSSL_add_all_ciphers() {
    OPENSSL_init_crypto(OPENSSL_INIT_ADD_ALL_CIPHERS, NULL);
}

#undef OpenSSL_add_all_digests
static inline void OpenSSL_add_all_digests() {
    OPENSSL_init_crypto(OPENSSL_INIT_ADD_ALL_DIGESTS, NULL);
}

#undef OpenSSL_add_all_algorithms
static inline void OpenSSL_add_all_algorithms() {
    #ifdef OPENSSL_LOAD_CONF
    OPENSSL_add_all_algorithms_conf();
    #else
    OPENSSL_add_all_algorithms_noconf();
    #endif
}
#endif

typedef unsigned char byte;

extern	void openssl_init(void);
extern	void malloc_free(const void *ptr);
extern	void openssl_bio_free(const void *ptr);

extern	const char *openssl_get_publickey_from_certificate(const char *certificate);

/*
extern	int openssl_sign_rsa_sha256_pkey_file(
		const byte *data,	// Data to be signed
		size_t dlen,		// Data byte length
		const char *filename,	// Private key (PEM) filename
		byte **sig,		// OUT: Signature
		size_t *slen);		// OUT: Signature byte length

extern	int openssl_sign_rsa_sha256_pkey_memory(
		const byte *data,	// Data to be signed
		size_t dlen,		// Data byte length
		const char *pkey,	// Private key (Base64 PEM) memory
		int plen,		// Private key memory byte len
		byte **sig,		// OUT: Signature
		size_t *slen);		// OUT: Signature byte length
*/

extern	int openssl_sign_rsa_sha256_pkey_file(
		const byte *data,	// Data to be signed
		size_t dlen,		// Data byte length
		const char *filename,	// Private key (PEM) filename
		byte *sig,		// OUT: Signature
		size_t *slen);		// OUT: Signature byte length

extern	int openssl_sign_rsa_sha256_pkey_string(
		const byte *data,	// Data to be signed
		size_t dlen,		// Data byte length
		const char *pkey,	// Private key (Base64 PEM) memory
		int plen,		// Private key memory byte len
		byte *sig,		// OUT: Signature
		size_t *slen);		// OUT: Signature byte length

extern	int openssl_verify_rsa_sha256_pubkey_string(
		const byte *data,	// Data that was signed
		size_t dlen,		// Data byte length
		const char *pkey,	// Public key (Base64 PEM) memory
		int plen,		// Public key memory byte len
		const byte *sig,	// Signature
		size_t slen);		// Signature byte length
