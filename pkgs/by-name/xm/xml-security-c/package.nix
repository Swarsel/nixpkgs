{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromCodeberg,
  openssl,
  pkg-config,
  unstableGitUpdater,
  xalanc,
  xercesc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xml-security-c";
  version = "3.0.0";

  src = fetchFromCodeberg {
    owner = "Shibboleth";
    repo = "cpp-xml-security";
    tag = finalAttrs.version;
    hash = "sha256-D60JtD4p9ERh6sowvwBHtE9XWVm3D8saooagDvA6ZtQ=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    xalanc
    xercesc
    openssl
  ];

  configureFlags = [
    "--with-openssl"
    "--with-xerces"
    "--with-xalan"
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "C++ Implementation of W3C security standards for XML";
    homepage = "https://shibboleth.atlassian.net/wiki/spaces/DEV/pages/3726671873/Santuario";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ drawbu ];
    platforms = lib.platforms.unix;
  };
})
