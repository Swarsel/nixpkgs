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
  pname = "corepad";
  version = "5.0.1";

  src = fetchFromGitLab {
    owner = "cubocore/coreapps";
    repo = "corepad";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TA/gwI7ukuwChBRp2xsDbNbTblkzYgQ5YHwuI53cxc8=";
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
    description = "Document editor from the C Suite";
    homepage = "https://gitlab.com/cubocore/coreapps/corepad";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "corepad";
  };
})
