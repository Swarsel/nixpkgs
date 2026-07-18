{
  lib,
  stdenv,
  fetchurl,
  glslang,
  libGL,
  libGLU,
  libdecor,
  libgbm,
  libglut,
  libx11,
  libxcb,
  libxext,
  libxkbcommon,
  mesa,
  meson,
  ninja,
  pkg-config,
  vulkan-loader,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mesa-demos";
  version = "9.0.0";

  src = fetchurl {
    url = "https://archive.mesa3d.org/demos/mesa-demos-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-MEaj0mp7BRr3690lel8jv+sWDK1u2VIynN/x6fHtSWs=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
    glslang
  ];

  buildInputs = [
    libglut
    libx11
    libxcb
    libxext
    libGL
    libGLU
    libgbm
    wayland
    wayland-protocols
    vulkan-loader
    libxkbcommon
    libdecor
  ];

  mesonFlags = [
    "-Degl=${if stdenv.hostPlatform.isDarwin then "disabled" else "auto"}"
    (lib.mesonEnable "libdrm" (stdenv.hostPlatform.isLinux))
    (lib.mesonEnable "osmesa" false)
    (lib.mesonEnable "wayland" (lib.meta.availableOn stdenv.hostPlatform wayland))
  ];

  depsBuildBuild = [
    pkg-config
  ];

  meta = {
    inherit (mesa.meta) homepage platforms;
    description = "Collection of demos and test programs for OpenGL and Mesa";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ andersk ];
  };
})
