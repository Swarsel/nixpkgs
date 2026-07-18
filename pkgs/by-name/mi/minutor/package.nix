{
  lib,
  stdenv,
  fetchFromGitHub,
  qt5,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "minutor";
  version = "26.1";

  src = fetchFromGitHub {
    owner = "mrkite";
    repo = "minutor";
    tag = finalAttrs.version;
    sha256 = "sha256-jz+3G1/4+QlUTRBOFKaTWPSBbJRcWDzFWsG+dqVFMBg=";
  };

  nativeBuildInputs = [
    qt5.qmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    zlib
  ];

  preConfigure = ''
    substituteInPlace minutor.pro \
      --replace-fail /usr "$out"
  '';

  meta = {
    inherit (qt5.qtbase.meta) platforms;
    description = "Easy to use mapping tool for Minecraft";
    homepage = "https://seancode.com/minutor/";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sternenseemann ];
    mainProgram = "minutor";
  };
})
