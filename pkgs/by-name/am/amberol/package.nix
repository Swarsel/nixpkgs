{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  blueprint-compiler,
  cargo,
  dbus,
  desktop-file-utils,
  glib,
  gst_all_1,
  gtk4,
  libadwaita,
  m4,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  reuse,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "amberol";
  version = "2026.1";

  src = fetchFromGitLab {
    owner = "World";
    repo = "amberol";
    tag = finalAttrs.version;
    hash = "sha256-d4lhfWqg6EZeXGL1kHGS7oWrqI3c9bpDCKUdGp31OpI=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    patchShebangs build-aux
  '';

  nativeBuildInputs = [
    appstream-glib
    blueprint-compiler
    cargo
    desktop-file-utils
    m4
    meson
    ninja
    pkg-config
    reuse
    rustc
    rustPlatform.cargoSetupHook
    wrapGAppsHook4
  ];

  buildInputs = [
    dbus
    glib
    gtk4
    libadwaita
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ]);

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-OFZd9nKRqXJMHSIIP8tlSNtFAQzk/f/6SBeEvbdPVK0=";
    name = "amberol-${finalAttrs.version}";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Small and simple sound and music player";
    homepage = "https://gitlab.gnome.org/World/amberol";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ linsui ];
    platforms = lib.platforms.linux;
    mainProgram = "amberol";
    teams = [ lib.teams.gnome-circle ];
  };
})
