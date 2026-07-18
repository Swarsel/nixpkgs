{
  lib,
  stdenv,
  autoreconfHook,
  boost,
  curl,
  fetchFromCodeberg,
  log4shib,
  openssl,
  pkg-config,
  unstableGitUpdater,
  xercesc,
  xml-security-c,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xml-tooling-c";
  version = "3.3.0";

  src = fetchFromCodeberg {
    owner = "Shibboleth";
    repo = "cpp-xmltooling";
    tag = finalAttrs.version;
    hash = "sha256-czmBu7ThDwq+x7FahgZDMHqid8jeUNnTuKMI/Fj4IIw=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    boost
    curl
    openssl
    log4shib
    xercesc
    xml-security-c
  ];

  configureFlags = [
    "--with-boost=${boost.dev}"
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString (!stdenv.hostPlatform.isDarwin) "-std=c++14";
  enableParallelBuilding = true;
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Low-level library that provides a high level interface to XML processing for OpenSAML 2";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sigmanificient ];
    platforms = lib.platforms.unix;
  };
})
