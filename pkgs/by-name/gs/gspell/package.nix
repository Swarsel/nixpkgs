{
  lib,
  stdenv,
  fetchurl,
  docbook-xsl-nons,
  enchant,
  glib,
  gnome,
  gobject-introspection,
  gtk-doc,
  gtk3,
  icu,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation rec {
  pname = "gspell";
  version = "1.14.4";

  src = fetchurl {
    url = "mirror://gnome/sources/gspell/${lib.versions.majorMinor version}/gspell-${version}.tar.xz";
    hash = "sha256-5zqJ1oxw+HSK77aw9c/f7D/xc89ESYN/1ssX0en89IY=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    docbook-xsl-nons
    glib # glib-mkenums
    gobject-introspection
    gtk-doc
    meson
    ninja
    pkg-config
    vala
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    gtk3
    icu
  ];

  propagatedBuildInputs = [
    # required for pkg-config
    enchant
  ];

  outputBin = "dev";

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "none";
    };
  };

  meta = {
    description = "Spell-checking library for GTK applications";
    homepage = "https://gitlab.gnome.org/GNOME/gspell";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gspell-app1";
    teams = [ lib.teams.gnome ];
  };
}
