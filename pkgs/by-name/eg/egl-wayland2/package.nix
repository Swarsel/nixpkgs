{
  lib,
  stdenv,
  fetchFromGitHub,
  eglexternalplatform,
  libGL,
  libdrm,
  libgbm,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "egl-wayland2";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "egl-wayland2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Udr+tihx/Si2ynFyM1FW2CIUgTg9SQn7AgrOPpGTxpY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    libGL
    libgbm
    libdrm
    wayland
    wayland-protocols
    eglexternalplatform
  ];

  __structuredAttrs = true;
  absolutizeEglExternalPlatformIcdJson = true;

  depsBuildBuild = [
    pkg-config
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Dma-buf-based Wayland external platform library";
    homepage = "https://github.com/NVIDIA/egl-wayland2/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      vancluever
      ccicnce113424
    ];

    platforms = lib.platforms.linux;
  };
})
