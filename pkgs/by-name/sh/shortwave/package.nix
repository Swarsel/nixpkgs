{
  lib,
  stdenv,
  fetchFromGitLab,
  cargo,
  dbus,
  desktop-file-utils,
  gdk-pixbuf,
  gettext,
  gitMinimal,
  glib,
  glib-networking,
  gst_all_1,
  gtk4,
  lcms2,
  libadwaita,
  libglycin-gtk4,
  libseccomp,
  libshumate,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  sqlite,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "shortwave";
  version = "5.1.0";

  src = fetchFromGitLab {
    owner = "World";
    repo = "Shortwave";
    rev = version;
    hash = "sha256-MiaozChp5QF/Q0fCTCgnyGJLyIftTkMAbmfRQ/73QP8=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    gitMinimal
    glib # for glib-compile-schemas
    meson
    ninja
    pkg-config
    cargo
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    dbus
    gdk-pixbuf
    glib
    glib-networking
    gtk4
    libadwaita
    libglycin-gtk4
    openssl
    sqlite
    libshumate
    libseccomp
    libxml2
    lcms2
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ]);

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-v6aphHunZrXPiuKRFT+EcWJySmQOOT433ST+m8j1z4w=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Find and listen to internet radio stations";
    homepage = "https://gitlab.gnome.org/World/Shortwave";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ lasandell ];
    platforms = lib.platforms.linux;
    mainProgram = "shortwave";
    teams = [ lib.teams.gnome-circle ];
  };
}
