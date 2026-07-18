{
  lib,
  stdenv,
  fetchurl,
  gdk-pixbuf,
  gettext,
  glib,
  gnome,
  gtk4,
  itstool,
  libadwaita,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "lightsoff";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/lightsoff/${lib.versions.major version}/lightsoff-${version}.tar.xz";
    hash = "sha256-uqDBdDHoXu7eXmSfUxYvcLTrHnx6bxak7KowJ7ZTFXg=";
  };

  postPatch = ''
    chmod +x build-aux/meson_post_install.py
    patchShebangs build-aux/meson_post_install.py
    substituteInPlace build-aux/meson_post_install.py \
      --replace-fail "gtk-update-icon-cache" "gtk4-update-icon-cache"
  '';

  nativeBuildInputs = [
    vala
    pkg-config
    wrapGAppsHook4
    itstool
    gettext
    libxml2
    meson
    ninja
    python3
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "lightsoff"; };
  };

  meta = {
    description = "Puzzle game, where the objective is to turn off all of the tiles on the board";
    homepage = "https://gitlab.gnome.org/GNOME/lightsoff";
    changelog = "https://gitlab.gnome.org/GNOME/lightsoff/-/blob/${version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    mainProgram = "lightsoff";
    teams = [ lib.teams.gnome ];
  };
}
