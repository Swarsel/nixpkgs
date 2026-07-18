{
  lib,
  stdenv,
  fetchpatch,
  fetchzip,
  zlib,
  zopfli,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gif2apng";
  version = "1.9";

  src = fetchzip {
    url = "mirror://sourceforge/gif2apng/gif2apng-${finalAttrs.version}-src.zip";
    hash = "sha256-rt1Vp4hjeFAVWJOU04BdU2YvBwECe9Q1c7EpNpIN+uE=";
    stripRoot = false;
  };

  patches = [
    (fetchpatch {
      hash = "sha256-zQgSWP/CIGaTUIxP/X92zpAQVSGgVo8gQEoCCMn+XT0=";
      url = "https://sources.debian.org/data/main/g/gif2apng/1.9%2Bsrconly-3%2Bdeb11u1/debian/patches/10-7z.patch";
    })
    (fetchpatch {
      hash = "sha256-ZDN3xgvktgahDEtrEpyVsL+4u+97Fo9vAB1RSKhu8KA=";
      url = "https://sources.debian.org/data/main/g/gif2apng/1.9%2Bsrconly-3%2Bdeb11u1/debian/patches/CVE-2021-45909.patch";
    })
    (fetchpatch {
      hash = "sha256-MzOUOC7kqH22DmTMXoDu+jZAMBJPndnFNJGAQv5FcdI=";
      url = "https://sources.debian.org/data/main/g/gif2apng/1.9%2Bsrconly-3%2Bdeb11u1/debian/patches/CVE-2021-45910.patch";
    })
    (fetchpatch {
      hash = "sha256-o2YDHsSaorCx/6bQQfudzkLHo9pakgyvs2Pbafplnek=";
      url = "https://sources.debian.org/data/main/g/gif2apng/1.9%2Bsrconly-3%2Bdeb11u1/debian/patches/CVE-2021-45911.patch";
    })
  ];

  # Remove bundled libs
  postPatch = ''
    rm -r 7z zlib zopfli
  '';

  buildInputs = [
    zlib
    zopfli
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}c++" ];
  env.NIX_CFLAGS_COMPILE = "-DENABLE_LOCAL_ZOPFLI";

  preBuild = ''
    buildFlagsArray+=("LIBS=-lzopfli -lstdc++ -lz")
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 gif2apng $out/bin/gif2apng
    runHook postInstall
  '';

  meta = {
    description = "Simple program that converts animations from GIF to APNG format";
    homepage = "https://gif2apng.sourceforge.net/";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
  };
})
