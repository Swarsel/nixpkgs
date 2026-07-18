{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk3,
  libepoxy,
  meson,
  ninja,
  pkg-config,
  wayland,
  wayland-scanner,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wdisplays";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "artizirk";
    repo = "wdisplays";
    rev = finalAttrs.version;
    sha256 = "sha256-KabaW2BH4zAS0xWkzCM8YaAnP/hkZL7Wq3EARantRis=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
    wayland-scanner
  ];

  buildInputs = [
    gtk3
    libepoxy
    wayland
  ];

  meta = {
    description = "Graphical application for configuring displays in Wayland compositors";
    homepage = "https://github.com/artizirk/wdisplays";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ma27 ];
    platforms = lib.platforms.linux;
    mainProgram = "wdisplays";
  };
})
