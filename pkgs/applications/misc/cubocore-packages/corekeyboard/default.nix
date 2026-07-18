{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  libcprime,
  libcsys,
  libx11,
  libxtst,
  ninja,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "corekeyboard";
  version = "5.0.1";

  src = fetchFromGitLab {
    owner = "cubocore/coreapps";
    repo = "corekeyboard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HAkIhmQzicnOAws8M+Z8J7lCuGUqYkJeQl0H8P0EE3c=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    libxtst
    libx11
    libcprime
    libcsys
  ];

  meta = {
    description = "Virtual keyboard for X11 from the C Suite";
    homepage = "https://gitlab.com/cubocore/coreapps/corekeyboard";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "corekeyboard";
  };
})
