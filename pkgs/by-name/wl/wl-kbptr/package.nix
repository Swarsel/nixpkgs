{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  gtk3,
  libxkbcommon,
  meson,
  ninja,
  opencv,
  pixman,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wl-kbptr";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "moverest";
    repo = "wl-kbptr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Z0ECLxkJChGe2ggwFRuKJj+J6+KcTAlZclqdvBzZDzs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    gtk3
    libxkbcommon
    opencv
    pixman
    wayland
    wayland-protocols
  ];

  mesonFlags = [ "-Dopencv=enabled" ];
  depsBuildBuild = [ pkg-config ];

  passthru = {
    updateScript = gitUpdater { };
  };

  meta = {
    inherit (wayland.meta) platforms;
    description = "Control the mouse pointer with the keyboard on Wayland";
    homepage = "https://github.com/moverest/wl-kbptr";
    changelog = "https://github.com/moverest/wl-kbptr/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3;

    maintainers = [
      lib.maintainers.luftmensch-luftmensch
      lib.maintainers.clementpoiret
    ];

    mainProgram = "wl-kbptr";
  };
})
