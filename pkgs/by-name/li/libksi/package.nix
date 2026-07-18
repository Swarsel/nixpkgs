{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  curl,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libksi";
  version = "3.21.3087";

  src = fetchFromGitHub {
    owner = "Guardtime";
    repo = "libksi";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-zEWxJpv0MeGUq/xkM26tDoauFyw53enGyWVhlX0jlYI=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    openssl
    curl
  ];

  configureFlags = [
    "--with-openssl=${openssl.dev}"
    "--with-cafile=/etc/ssl/certs/ca-certificates.crt"
  ];

  meta = {
    description = "Keyless Signature Infrastructure API library";
    homepage = "https://github.com/GuardTime/libksi";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})
