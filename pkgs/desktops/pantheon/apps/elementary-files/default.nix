{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  glib,
  granite,
  gtk3,
  libcanberra,
  libcloudproviders,
  libgee,
  libgit2-glib,
  libhandy,
  libportal-gtk3,
  meson,
  ninja,
  nix-update-script,
  pango,
  pkg-config,
  poppler_gi,
  sqlite,
  systemd,
  vala,
  wrapGAppsHook3,
  zeitgeist,
}:

stdenv.mkDerivation rec {
  pname = "elementary-files";
  version = "7.3.1";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "files";
    rev = version;
    hash = "sha256-53JzGLlRIeRVq54/YbZd24M8DiS2LuTvgC3/0pRrja4=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    granite
    gtk3
    libcanberra
    libcloudproviders
    libgee
    libgit2-glib
    libhandy
    libportal-gtk3
    pango
    poppler_gi
    sqlite
    systemd
    zeitgeist
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "File browser designed for elementary OS";
    homepage = "https://github.com/elementary/files";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.files";
    teams = [ lib.teams.pantheon ];
  };
}
