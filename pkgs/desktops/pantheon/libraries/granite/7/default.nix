{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  glib,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk4,
  libgee,
  libshumate,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  sassc,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "granite";
  version = "7.8.1";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "granite";
    tag = version;
    hash = "sha256-Hk5EiTMsSOg2eQQCbILDoibcmfS+4N//4go6rc06Qwc=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    gettext
    gobject-introspection
    meson
    ninja
    pkg-config
    sassc
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    libshumate # demo
  ];

  propagatedBuildInputs = [
    glib
    gsettings-desktop-schemas # is_clock_format_12h uses "org.gnome.desktop.interface clock-format"
    gtk4
    libgee
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Extension to GTK used by elementary OS";

    longDescription = ''
      Granite is a companion library for GTK and GLib. Among other things, it provides complex widgets and convenience functions
      designed for use in apps built for elementary OS.
    '';

    homepage = "https://github.com/elementary/granite";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "granite-7-demo";
    teams = [ lib.teams.pantheon ];
  };
}
