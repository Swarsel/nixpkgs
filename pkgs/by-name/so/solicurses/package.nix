{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
}:

stdenv.mkDerivation {
  pname = "solicurses";
  version = "0-unstable-2020-02-13";

  src = fetchFromGitHub {
    owner = "KaylaPP";
    repo = "SoliCurses";
    rev = "dc89ca00fc1711dc449d0a594a4727af22fc35a0";
    sha256 = "sha256-zWYXpvEnViT/8gsdMU9Ymi4Hw+nwkG6FT/3h5sNMCE4=";
  };

  buildInputs = [
    ncurses
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}c++"
  ];

  preBuild = ''
    cd build
  '';

  installPhase = ''
    install -D SoliCurses.out $out/bin/solicurses
  '';

  meta = {
    inherit (ncurses.meta) platforms;
    description = "Version of Solitaire written in C++ using the ncurses library";
    homepage = "https://github.com/KaylaPP/SoliCurses";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ laalsaas ];
    mainProgram = "solicurses";
  };
}
