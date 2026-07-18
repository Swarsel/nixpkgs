{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fontconfig,
  freetype,
  libjpeg,
  libpng,
  libtiff,
  libxml2,
  openssl,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "podofo";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "podofo";
    repo = "podofo";
    rev = finalAttrs.version;
    hash = "sha256-y+3nOynd0xJRF14XA1oK2smL6irCfaFrJ8rvxJS6b8M=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    fontconfig
    freetype
    libjpeg
    libpng
    libtiff
    libxml2
    openssl
    zlib
  ];

  cmakeFlags = [
    (lib.cmakeBool "PODOFO_BUILD_STATIC" stdenv.hostPlatform.isStatic)
    (lib.cmakeBool "CMAKE_BUILD_WITH_INSTALL_NAME_DIR" true)
  ];

  __structuredAttrs = true;

  meta = {
    description = "Library to work with the PDF file format";
    homepage = "https://github.com/podofo/podofo";
    changelog = "https://github.com/podofo/podofo/blob/${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
    ];

    maintainers = with lib.maintainers; [
      kuflierl
    ];

    platforms = lib.platforms.all;
  };
})
