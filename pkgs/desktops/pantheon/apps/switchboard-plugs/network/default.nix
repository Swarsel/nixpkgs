{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  granite7,
  gtk4,
  libadwaita,
  libgee,
  libnma-gtk4,
  meson,
  networkmanager,
  networkmanagerapplet,
  ninja,
  nix-update-script,
  pkg-config,
  replaceVars,
  switchboard,
  vala,
}:

stdenv.mkDerivation rec {
  pname = "switchboard-plug-network";
  version = "8.2.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "switchboard-plug-network";
    rev = version;
    hash = "sha256-H43mRPEujs6A4Bk2uC3mP91Hp5I8gojaagoXUT/5eW8=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      inherit networkmanagerapplet;
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
    granite7
    gtk4
    libadwaita
    libgee
    networkmanager
    libnma-gtk4
    switchboard
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Switchboard Networking Plug";
    homepage = "https://github.com/elementary/switchboard-plug-network";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
