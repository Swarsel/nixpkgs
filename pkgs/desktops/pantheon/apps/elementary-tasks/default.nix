{
  lib,
  stdenv,
  fetchFromGitHub,
  clutter-gtk,
  evolution-data-server,
  geoclue2,
  geocode-glib_2,
  granite,
  gtk3,
  libchamplain_libsoup3,
  libgee,
  libhandy,
  libical,
  libportal-gtk3,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "elementary-tasks";
  version = "6.3.3";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "tasks";
    rev = version;
    hash = "sha256-xOMS4Zwfl7TLHvm8Zn6wQ4ZoMg+Yuci+cTpUVG+liss=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    clutter-gtk
    evolution-data-server
    granite
    geoclue2
    geocode-glib_2
    gtk3
    libchamplain_libsoup3
    libgee
    libhandy
    libical
    libportal-gtk3
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Synced tasks and reminders on elementary OS";
    homepage = "https://github.com/elementary/tasks";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.tasks";
    teams = [ lib.teams.pantheon ];
  };
}
