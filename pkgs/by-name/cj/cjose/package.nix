{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  check,
  doxygen,
  fetchpatch,
  jansson,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cjose";
  version = "0.6.2.2";

  src = fetchFromGitHub {
    owner = "OpenIDC";
    repo = "cjose";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-vDvCxMpgCdteGvNxy2HCNRaxbhxOuTadL0nM2wkFHtk=";
  };

  patches = [
    # avoid using empty prototypes; support Clang 15 and XCode 14.3 - https://github.com/OpenIDC/cjose/pull/19
    (fetchpatch {
      hash = "sha256-+C5AIejb9InOGiOgUNfuP89J18O71rnq1pXyroxEDFQ=";
      url = "https://github.com/OpenIDC/cjose/commit/63e90cf464d6a470e26886435e8d7d96a66747f6.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    doxygen
  ];

  buildInputs = [
    jansson
    openssl
  ];

  configureFlags = [
    "--with-jansson=${jansson}"
    "--with-openssl=${openssl.dev}"
  ];

  nativeCheckInputs = [ check ];

  meta = {
    description = "C library for Javascript Object Signing and Encryption. This is a maintained fork of the original project";
    homepage = "https://github.com/OpenIDC/cjose";
    changelog = "https://github.com/OpenIDC/cjose/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ midchildan ];
    platforms = lib.platforms.all;
  };
})
