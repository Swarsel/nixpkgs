{
  lib,
  stdenv,
  autoreconfHook,
  boost,
  fetchFromCodeberg,
  log4shib,
  openssl,
  pkg-config,
  unstableGitUpdater,
  xercesc,
  xml-security-c,
  xml-tooling-c,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opensaml-cpp";
  version = "3.0.1";

  src = fetchFromCodeberg {
    owner = "Shibboleth";
    repo = "cpp-opensaml";
    tag = finalAttrs.version;
    hash = "sha256-iBfKM40SzCiDGHacnxc7zZdvOYbCy9NEWjhPzCvWQ1c=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    boost
    openssl
    log4shib
    xercesc
    xml-security-c
    xml-tooling-c
    zlib
  ];

  configureFlags = [
    "--with-boost=${boost.dev}"
    "--with-xmltooling=${xml-tooling-c}"
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString (!stdenv.hostPlatform.isDarwin) "-std=c++14";
  enableParallelBuilding = true;
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Low-level library written in C++ that provides support for producing and consuming SAML messages";
    homepage = "https://shibboleth.net/products/opensaml-cpp.html";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ drawbu ];
    platforms = lib.platforms.unix;
    mainProgram = "samlsign";
  };
})
