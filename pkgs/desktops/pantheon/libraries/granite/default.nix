{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  glib,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk3,
  libgee,
  meson,
  ninja,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "granite";
  version = "6.2.0"; # nixpkgs-update: no auto update

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "granite";
    rev = version;
    sha256 = "sha256-WM0Wo9giVP5pkMFaPCHsMfnAP6xD71zg6QLCYV6lmkY=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  nativeBuildInputs = [
    gettext
    gobject-introspection
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook3
  ];

  propagatedBuildInputs = [
    glib
    gsettings-desktop-schemas # is_clock_format_12h uses "org.gnome.desktop.interface clock-format"
    gtk3
    libgee
  ];

  meta = {
    description = "Extension to GTK used by elementary OS";

    longDescription = ''
      Granite is a companion library for GTK and GLib. Among other things, it provides complex widgets and convenience functions
      designed for use in apps built for elementary OS.
    '';

    homepage = "https://github.com/elementary/granite";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "granite-demo";
    teams = [ lib.teams.pantheon ];
  };
}
