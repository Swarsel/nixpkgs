{
  lib,
  stdenv,
  fetchFromGitHub,
  qt5,
}:

stdenv.mkDerivation {
  pname = "r3ctl";
  version = "a82cb5b3123224e706835407f21acea9dc7ab0f0";

  src = fetchFromGitHub {
    owner = "0xfeedc0de64";
    repo = "r3ctl";
    rev = "a82cb5b3123224e706835407f21acea9dc7ab0f0";
    sha256 = "5/L8jvEDJGJzsuAxPrctSDS3d8lbFX/+f52OVyGQ/RY=";
  };

  nativeBuildInputs = [
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qttools
    qt5.qtmultimedia
    qt5.qtwebsockets
  ];

  buildPhase = ''
    qmake .
    make
  '';

  postInstall = ''
    mv bin $out
  '';

  meta = {
    description = "Cmdline tool to control the r3 hackerspace lights";
    homepage = "https://github.com/0xfeedc0de64/r3ctl";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ mkg20001 ];
    platforms = lib.platforms.linux;
    mainProgram = "r3ctl";
  };
}
