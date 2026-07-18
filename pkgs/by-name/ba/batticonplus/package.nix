{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  glib,
  gtk3,
  libayatana-appindicator,
  libnotify,
  nix-update-script,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "batticonplus";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "artist4artixlinux";
    repo = "batticonplus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H9ZoiQ5zWMIoWWol2a6f9Z8g4o9DIHYdF+/nEsBfuzc=";
  };

  nativeBuildInputs = [
    pkg-config
    gettext
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    libnotify
    libayatana-appindicator
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "WITH_APPINDICATOR=1"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight battery status icon for the system tray and notifier (based on cbatticon)";
    homepage = "https://github.com/artist4artixlinux/batticonplus";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ yechielw ];
    platforms = lib.platforms.linux;
    mainProgram = "batticonplus";
  };
})
