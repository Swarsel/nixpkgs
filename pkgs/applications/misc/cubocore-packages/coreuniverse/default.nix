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
  pname = "coreuniverse";
  version = "5.0.0";

  src = fetchFromGitLab {
    owner = "cubocore/coreapps";
    repo = "coreuniverse";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T5BYHzOqSED40hOc5VwD+oLTwBJ1wARvS8MwiYOWlXM=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    libcprime
    libcsys
  ];

  meta = {
    description = "Shows information about apps from the C Suite";
    homepage = "https://gitlab.com/cubocore/coreapps/coreuniverse";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "coreuniverse";
  };
})
