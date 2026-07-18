{
  lib,
  stdenv,
  fetchFromGitHub,
  jansson,
  libxcrypt,
  openssl,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ircd-hybrid";
  version = "8.2.47";

  src = fetchFromGitHub {
    owner = "ircd-hybrid";
    repo = "ircd-hybrid";
    tag = finalAttrs.version;
    hash = "sha256-A6YWKtwqCWfP3fvuSxXFer21T+RMOfR+OhKiYbQpUao=";
  };

  buildInputs = [
    jansson
    openssl
    zlib
    libxcrypt
  ];

  configureFlags = [
    "--with-nicklen=100"
    "--with-topiclen=360"
    "--enable-openssl=${openssl.dev}"
  ];

  postInstall = "echo postinstall; mkdir -p \${out}/ ; rm -rf \${out}/logs ; ln -s /home/ircd \${out}/logs;";

  meta = {
    description = "IPv6-capable IRC server";
    homepage = "https://www.ircd-hybrid.org/";
    maintainers = with lib.maintainers; [ tbutter ];
    platforms = lib.platforms.unix;
  };
})
