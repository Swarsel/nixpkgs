{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6,
}:

stdenv.mkDerivation rec {
  pname = "fotowall";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "fotowall";
    repo = "fotowall";
    rev = "v${version}";
    hash = "sha256-icZUT17vgpI65Vyx7/TuTP4ISDkb7mrXwuyVzDHcoNE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
  ];

  __structuredAttrs = true;

  meta = {
    description = "Pictures collage & creativity tool";
    homepage = "https://github.com/fotowall/fotowall";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "fotowall";
  };
}
