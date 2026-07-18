{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus,
  glib,
  glib-networking,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "contractor";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "contractor";
    rev = version;
    sha256 = "1sqww7zlzl086pjww3d21ah1g78lfrc9aagrqhmsnnbji9gwb8ab";
  };

  nativeBuildInputs = [
    dbus
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    glib-networking
    libgee
  ];

  env.PKG_CONFIG_DBUS_1_SESSION_BUS_SERVICES_DIR = "${placeholder "out"}/share/dbus-1/services";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Desktop-wide extension service used by elementary OS";
    homepage = "https://github.com/elementary/contractor";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "contractor";
    teams = [ lib.teams.pantheon ];
  };
}
