{
  lib,
  stdenv,
  cli11,
  cmake,
  cpptrace,
  fetchFromGitea,
  glib,
  jemalloc,
  libdrm,
  libgbm,
  libxcb,
  ninja,
  pam,
  pipewire,
  pkg-config,
  polkit,
  qt6,
  spirv-tools,
  vulkan-headers,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "quickshell";
  version = "0.3.0";

  # github mirror: https://github.com/quickshell-mirror/quickshell
  src = fetchFromGitea {
    owner = "quickshell";
    repo = "quickshell";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gU+VGpwGJ2vvg0mtYqVvj5u+2LteuHlpokH6JSAtueY=";
    domain = "git.outfoxxed.me";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.qtshadertools
    spirv-tools
    vulkan-headers
    wayland-scanner
    qt6.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtwayland
    qt6.qtsvg
    cli11
    wayland
    wayland-protocols
    libdrm
    libgbm
    cpptrace
    jemalloc
    libxcb
    pam
    pipewire
    glib
    polkit
  ];

  cmakeFlags = [
    (lib.cmakeFeature "DISTRIBUTOR" "Nixpkgs")
    (lib.cmakeFeature "INSTALL_QML_PREFIX" qt6.qtbase.qtQmlPrefix)
    (lib.cmakeFeature "GIT_REVISION" "tag-v${finalAttrs.version}")
  ];

  cmakeBuildType = "RelWithDebInfo";
  dontStrip = false;
  separateDebugInfo = true;

  meta = {
    description = "Flexbile QtQuick based desktop shell toolkit";
    homepage = "https://quickshell.org";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ outfoxxed ];
    platforms = lib.platforms.linux;
    mainProgram = "quickshell";
  };
})
