{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  docutils,
  gtk-layer-shell,
  gtk3,
  json_c,
  libmpdclient,
  libpulseaudio,
  libxkbcommon,
  makeWrapper,
  meson,
  ninja,
  pipewire,
  pkg-config,
  wayland-scanner,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sfwbar";
  version = "1.0_beta17";

  src = fetchFromGitHub {
    owner = "LBCrion";
    repo = "sfwbar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xenXcGo5kdntOsSOlXaYA9WZ9Ed0hncGlb5Jgv6rbio=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    makeWrapper
    wayland-scanner
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    json_c
    gtk-layer-shell
    libpulseaudio
    libmpdclient
    libxkbcommon
    pipewire
    alsa-lib
    docutils # for rst2man
  ];

  meta = {
    description = "Flexible taskbar application for wayland compositors, designed with a stacking layout in mind";
    homepage = "https://github.com/LBCrion/sfwbar";
    changelog = "https://github.com/LBCrion/sfwbar/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      luftmensch-luftmensch
      NotAShelf
    ];

    platforms = lib.platforms.linux;
    mainProgram = "sfwbar";
  };
})
