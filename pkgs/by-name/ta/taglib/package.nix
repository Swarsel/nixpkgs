{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  testers,
  utf8cpp,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "taglib";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "taglib";
    repo = "taglib";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xup/c1giZadq8jYQgsZW+NJkjw9ofpdivnBVKTVkRjU=";
  };

  strictDeps = true;
  nativeBuildInputs = [ cmake ];

  buildInputs = [
    zlib
    utf8cpp
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ];

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "Library for reading and editing audio file metadata";

    longDescription = ''
      TagLib is a library for reading and editing the meta-data of several
      popular audio formats. Currently it supports both ID3v1 and ID3v2 for MP3
      files, Ogg Vorbis comments and ID3 tags and Vorbis comments in FLAC, MPC,
      Speex, WavPack, TrueAudio, WAV, AIFF, MP4 and ASF files.
    '';

    homepage = "https://taglib.org/";

    license = with lib.licenses; [
      lgpl21Only
      mpl11
    ];

    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "taglib-config";

    pkgConfigModules = [
      "taglib"
      "taglib_c"
    ];
  };
})
