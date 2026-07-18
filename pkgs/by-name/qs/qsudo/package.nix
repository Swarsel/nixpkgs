{
  lib,
  stdenv,
  fetchFromGitHub,
  libsForQt5,
  sudo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qsudo";
  version = "2020.03.27";

  src = fetchFromGitHub {
    owner = "project-trident";
    repo = "qsudo";
    tag = "v${finalAttrs.version}";
    sha256 = "06kg057vwkvafnk69m9rar4wih3vq4h36wbzwbfc2kndsnn47lfl";
  };

  postPatch = ''
    substituteInPlace qsudo.pro --replace /usr/bin $out/bin
  '';

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    sudo
  ];

  sourceRoot = "${finalAttrs.src.name}/src-qt5";

  meta = {
    description = "Graphical sudo utility from Project Trident";
    homepage = "https://github.com/project-trident/qsudo";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
    mainProgram = "qsudo";
  };
})
