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
  pname = "corehunt";
  version = "5.0.1";

  src = fetchFromGitLab {
    owner = "cubocore/coreapps";
    repo = "corehunt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D3O1RnhXZmIGlk75OxfYvQI+8sytXTho2MvccI5Xyvg=";
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
    description = "File finder utility from the C Suite";
    homepage = "https://gitlab.com/cubocore/coreapps/corehunt";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "corehunt";
  };
})
