{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libx11,
  meson,
  ninja,
  pkg-config,
  unstableGitUpdater,
  vulkan-headers,
  vulkan-loader,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation {
  pname = "vulkan-hdr-layer-kwin6";
  version = "0-unstable-2026-03-25";

  src = fetchFromGitHub {
    owner = "Zamundaaa";
    repo = "VK_hdr_layer";
    rev = "57b26b8927b133566be13a7702f74a62109bad15";
    hash = "sha256-E1j3s6Ie8jLY5CFaNoOs/ffbUGloK0ZUC5vLwjwsrZw=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
    wayland-scanner
  ];

  buildInputs = [
    vulkan-headers
    vulkan-loader
    libx11
    wayland
  ];

  depsBuildBuild = [ pkg-config ];
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Vulkan Wayland HDR WSI Layer (Xaver Hugl's fork for KWin 6)";
    homepage = "https://github.com/Zamundaaa/VK_hdr_layer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ d4rk ];
    platforms = lib.platforms.linux;
  };
}
