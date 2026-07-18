{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  cargo,
  dbus,
  desktop-file-utils,
  git,
  glib,
  gst_all_1,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "audio-sharing";
  version = "0.2.4";

  src = fetchFromGitLab {
    owner = "World";
    repo = "AudioSharing";
    rev = finalAttrs.version;
    hash = "sha256-yUMiy5DaCPfCmBIGCXpqtvSSmQl5wo6vsLdW7Tt/Wfo=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    appstream-glib
    cargo
    desktop-file-utils
    git
    meson
    ninja
    pkg-config
    python3
    rustc
    wrapGAppsHook4
  ]
  ++ (with rustPlatform; [
    cargoSetupHook
  ]);

  buildInputs = [
    glib
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good # pulsesrc
    gst_all_1.gst-rtsp-server
    gst_all_1.gstreamer
    gtk4
    libadwaita
    dbus
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-ePgEAVYXLOHWQXG92Grb9nmenyGj0JkgVy1UDsQF0xw=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Automatically share the current audio playback in the form of an RTSP stream";
    homepage = "https://gitlab.gnome.org/World/AudioSharing";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ benediktbroich ];
    platforms = lib.platforms.linux;
    mainProgram = "audio-sharing";
    teams = [ lib.teams.gnome-circle ];
  };
})
