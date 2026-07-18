{
  lib,
  stdenv,
  cmake,
  fetchzip,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zdbsp";
  version = "1.19";

  src = fetchzip {
    url = "https://zdoom.org/files/utils/zdbsp/zdbsp-${finalAttrs.version}-src.zip";
    sha256 = "sha256-DTj0jMNurvwRwMbo0L4+IeNlbfIwUbqcG1LKd68C08g=";
    stripRoot = false;
  };

  patches = [
    # https://github.com/rheit/zdbsp/pull/7
    ./fix-cmake-version.patch
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    zlib
  ];

  installPhase = ''
    install -Dm755 zdbsp $out/bin/zdbsp
  '';

  meta = {
    description = "ZDoom's internal node builder for DOOM maps";
    homepage = "https://zdoom.org/wiki/ZDBSP";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      lassulus
      siraben
    ];

    platforms = lib.platforms.unix;
    mainProgram = "zdbsp";
  };
})
