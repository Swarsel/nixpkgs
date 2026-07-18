{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  granite7,
  gtk4,
  libadwaita,
  libgee,
  libical,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  replaceVars,
  switchboard,
  tzdata,
  vala,
}:

stdenv.mkDerivation rec {
  pname = "switchboard-plug-datetime";
  version = "8.1.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "switchboard-plug-datetime";
    rev = version;
    sha256 = "sha256-VOL0F0obuXVz0G5hMI/hpUf2T3H8XUw64wu4MxRi57g=";
  };

  patches = [
    (replaceVars ./fix-paths.patch {
      tzdata = tzdata;
    })
  ];

  nativeBuildInputs = [
    gettext # msgfmt
    libxml2
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
    libical
    switchboard
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Switchboard Date & Time Plug";
    homepage = "https://github.com/elementary/switchboard-plug-datetime";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.pantheon ];
  };
}
