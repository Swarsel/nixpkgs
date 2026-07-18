{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  cargo,
  dbus,
  desktop-file-utils,
  gettext,
  glib,
  glib-networking,
  gst_all_1,
  gtk4,
  libadwaita,
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

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-podcasts";
  version = "25.3";

  src = fetchFromGitLab {
    owner = "World";
    repo = "podcasts";
    tag = finalAttrs.version;
    hash = "sha256-SblEHmKB/WZwT3T3vnlB4yJjY9JhftDkO21/yY//BRM=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cargo
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
    appstream-glib
    desktop-file-utils
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    gettext
    dbus
    openssl
    glib-networking
    sqlite
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-good
  ];

  # tests require network
  doCheck = false;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-Ii5M6W5v5t+qppQNZI1ypHGMM5urUMv7e3Fef3FjfAA=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Listen to your favorite podcasts";
    homepage = "https://apps.gnome.org/Podcasts/";
    changelog = "https://gitlab.gnome.org/World/podcasts/-/releases/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gnome-podcasts";
    broken = stdenv.hostPlatform.isDarwin; # never built on Hydra https://hydra.nixos.org/job/nixpkgs/trunk/gnome-podcasts.x86_64-darwin

    teams = [
      lib.teams.gnome
      lib.teams.gnome-circle
    ];
  };
})
