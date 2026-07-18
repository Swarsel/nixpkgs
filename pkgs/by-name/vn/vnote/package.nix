{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vnote";
  version = "3.20.1";

  src = fetchFromGitHub {
    owner = "vnotex";
    repo = "vnote";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ukik02qP7a86dgBTghD9wGKGpXkdGdxczg01APtcOAM=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      hash = "sha256-gt2JDO9kGR/bjTtqTaAdHDHm9UC3XMG6KgKeDdhhNNg=";
      url = "https://github.com/vnotex/vnote/commit/7c59d0d061d30f8f1f57eab855b73d3b1f452df1.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwebengine
    qt6.qtsvg
    qt6.qttools
    qt6.qt5compat
    qt6.qtwayland
  ];

  meta = {
    description = "Pleasant note-taking platform";
    homepage = "https://vnotex.github.io/vnote";
    changelog = "https://github.com/vnotex/vnote/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "vnote";
  };
})
