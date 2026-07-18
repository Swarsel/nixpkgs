{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  libcprime,
  libcsys,
  ninja,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "coreaction";
  version = "5.0.1";

  src = fetchFromGitLab {
    owner = "cubocore/coreapps";
    repo = "coreaction";
    tag = "v${finalAttrs.version}";
    hash = "sha256-93/1emCLXP3hHDGdzjF5horWkpG51yM5p68RUs1yoVg=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtsvg
    qt6.qtbase
    libcprime
    libcsys
  ];

  meta = {
    description = "Side bar for showing widgets from the C Suite";
    homepage = "https://gitlab.com/cubocore/coreapps/coreaction";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "coreaction";
  };
})
