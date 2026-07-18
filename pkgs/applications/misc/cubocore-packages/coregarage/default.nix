{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  libarchive,
  libarchive-qt,
  libcprime,
  libcsys,
  ninja,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "coregarage";
  version = "5.0.1";

  src = fetchFromGitLab {
    owner = "cubocore/coreapps";
    repo = "coregarage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aPBqlt/bL1cx6mLaf/gEFQB+NEvGQJioBJZ4QAxTwzw=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    libarchive
    libarchive-qt
    libcprime
    libcsys
  ];

  meta = {
    description = "Settings manager for the C Suite";
    homepage = "https://gitlab.com/cubocore/coreapps/coregarage";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "coregarage";
  };
})
