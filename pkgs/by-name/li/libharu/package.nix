{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libpng,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libharu";
  version = "2.4.6";

  src = fetchFromGitHub {
    owner = "libharu";
    repo = "libharu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Uy16fOZgGC7z8eUtQ6Y0R0B9vXEJcSnyBGQQamkDkik=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    zlib
    libpng
  ];

  meta = {
    description = "Cross platform, open source library for generating PDF files";
    homepage = "http://libharu.org/";
    changelog = "https://github.com/libharu/libharu/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.zlib;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
