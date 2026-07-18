{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cpp-utilities,
  isocodes,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tagparser";
  version = "12.5.3";

  src = fetchFromGitHub {
    owner = "Martchus";
    repo = "tagparser";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lXtr+jWP0SUBIdLIpfFKxqh5jWV0N1N28elLFjB/JZU=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    cpp-utilities
    zlib
  ];

  cmakeFlags = [
    "-DLANGUAGE_FILE_ISO_639_2=${isocodes}/share/iso-codes/json/iso_639-2.json"
  ];

  meta = {
    description = "C++ library for reading and writing MP4/M4A/AAC (iTunes), ID3, Vorbis, Opus, FLAC and Matroska tags";
    homepage = "https://github.com/Martchus/tagparser";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.matthiasbeyer ];
    platforms = lib.platforms.all;
  };
})
