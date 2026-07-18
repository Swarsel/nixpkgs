{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  granite7,
  gtk4,
  libadwaita,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pcre2,
  pkg-config,
  vala,
  vte-gtk4,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "elementary-terminal";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "terminal";
    tag = version;
    hash = "sha256-IzLaM9FPMRGJKvlXktyrhDYSyP4LJ8yFW8/FmsmZjU4=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    granite7
    gtk4
    libadwaita
    libgee
    pcre2
    vte-gtk4
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Terminal emulator designed for elementary OS";

    longDescription = ''
      A super lightweight, beautiful, and simple terminal. Comes with sane defaults, browser-class tabs, sudo paste protection,
      smart copy/paste, and little to no configuration.
    '';

    homepage = "https://github.com/elementary/terminal";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.terminal";
    teams = [ lib.teams.pantheon ];
  };
}
