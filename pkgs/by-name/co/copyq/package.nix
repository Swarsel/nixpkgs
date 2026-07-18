{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  kdePackages,
  libx11,
  libxfixes,
  libxtst,
  miniaudio,
  ninja,
  pkg-config,
  qt6,
  wayland,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "CopyQ";
  version = "16.0.0";

  src = fetchFromGitHub {
    owner = "hluk";
    repo = "CopyQ";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QO7iOFwO++tXZMWvJVmzUDrjnuz0Fl2XYsqfIPl5GBA=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    kdePackages.extra-cmake-modules
    qt6.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qttools
    qt6.qtdeclarative
    libx11
    libxfixes
    libxtst
    qt6.qtwayland
    wayland
    miniaudio
    kdePackages.kconfig
    kdePackages.kstatusnotifieritem
    kdePackages.knotifications
    kdePackages.kguiaddons
    kdePackages.qca
    kdePackages.qtkeychain
  ];

  cmakeFlags = [
    (lib.cmakeBool "WITH_QT6" true)
    (lib.cmakeFeature "MINIAUDIO_INCLUDE_DIR" "${lib.getInclude miniaudio}/include/miniaudio")
  ];

  meta = {
    description = "Clipboard Manager with Advanced Features";
    homepage = "https://hluk.github.io/CopyQ";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ artturin ];
    # NOTE: CopyQ supports windows and osx, but I cannot test these.
    platforms = lib.platforms.linux;
    mainProgram = "copyq";
  };
})
