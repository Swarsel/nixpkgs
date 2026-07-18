{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gettext,
  gnome,
  gtkmm4,
  itstool,
  libadwaita,
  libsecret,
  libuuid,
  libxml2,
  libxslt,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "gnote";
  version = "49.2";

  src = fetchurl {
    url = "mirror://gnome/sources/gnote/${lib.versions.major version}/gnote-${version}.tar.xz";
    hash = "sha256-lC8CsXIFff4HbdBNDwNlLqafNjg3Lsbrn8p3CBYEp7U=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    itstool
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtkmm4
    libadwaita
    libsecret
    libuuid
    libxml2
    libxslt
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
    };
  };

  meta = {
    description = "Note taking application";
    homepage = "https://gitlab.gnome.org/GNOME/gnote";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ jfvillablanca ];
    platforms = lib.platforms.linux;
    mainProgram = "gnote";
  };
}
