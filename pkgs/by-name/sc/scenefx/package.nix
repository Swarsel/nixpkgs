{
  lib,
  stdenv,
  fetchFromGitHub,
  libGL,
  libdrm,
  libgbm,
  libxcb,
  libxcb-wm,
  libxkbcommon,
  meson,
  ninja,
  pixman,
  pkg-config,
  scdoc,
  testers,
  validatePkgConfig,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_19,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scenefx";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "wlrfx";
    repo = "scenefx";
    tag = finalAttrs.version;
    hash = "sha256-XD5EcquaHBg5spsN06fPHAjVCb1vOMM7oxmjZZ/PxIE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    validatePkgConfig
    wayland-scanner
  ];

  buildInputs = [
    libdrm
    libGL
    libxkbcommon
    libgbm
    libxcb
    libxcb-wm
    pixman
    wayland
    wayland-protocols
    wlroots_0_19
  ];

  depsBuildBuild = [ pkg-config ];
  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "Drop-in replacement for the wlroots scene API that allows wayland compositors to render surfaces with eye-candy effects";
    homepage = "https://github.com/wlrfx/scenefx";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "scenefx";
    pkgConfigModules = [ "scenefx" ];
  };
})
