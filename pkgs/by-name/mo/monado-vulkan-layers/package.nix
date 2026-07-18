{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  vulkan-headers,
  vulkan-loader,
}:
stdenv.mkDerivation {
  pname = "monado-vulkan-layers";
  version = "0-unstable-2024-02-21";

  src = fetchFromGitLab {
    owner = "monado";
    repo = "utilities/vulkan-layers";
    rev = "ae43cdcbd25c56e3481bbc8a0ce2bfcebba9f7c2";
    sha256 = "sha256-QabYVKcenW+LQ+QSjUoQOLOQAVHdjE0YXd+1WsdzNPc=";
    domain = "gitlab.freedesktop.org";
  };

  patches = [
    ./absolute-layer-path.patch
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    vulkan-headers
    vulkan-loader
  ];

  meta = {
    description = "Vulkan Layers for Monado";
    homepage = "https://gitlab.freedesktop.org/monado/utilities/vulkan-layers";
    license = lib.licenses.boost;

    maintainers = with lib.maintainers; [
      Scrumplex
      passivelemon
    ];

    platforms = lib.platforms.linux;
  };
}
