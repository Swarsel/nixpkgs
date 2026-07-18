{
  lib,
  stdenv,
  fetchFromGitLab,
  desktop-file-utils,
  docbook_xml_dtd_45,
  docbook_xsl,
  gitUpdater,
  glib,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk-doc,
  gtk3,
  intltool,
  itstool,
  libxml2,
  meson,
  mesonEmulatorHook,
  ninja,
  pcre2,
  pkg-config,
  python3,
  runCommand,
  symlinkJoin,
  unicode-character-database,
  unihan-database,
  unzip,
  wrapGAppsHook3,
  yelp-tools,
}:

let
  # TODO: make upstream patch allowing to use the uncompressed file,
  # preferably from XDG_DATA_DIRS.
  # https://gitlab.gnome.org/GNOME/gucharmap/issues/13
  unihanZip = runCommand "unihan" { } ''
    mkdir -p $out/share/unicode
    ln -s ${unihan-database.src} $out/share/unicode/Unihan.zip
  '';
  ucd = symlinkJoin {
    name = "ucd+unihan";

    paths = [
      unihanZip
      unicode-character-database
    ];
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gucharmap";
  version = "17.0.2";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "gucharmap";
    rev = finalAttrs.version;
    hash = "sha256-LjXn8cFLqVZmLub0FRscyjg93u6g1EXsv3w0L4iiyqE=";
    domain = "gitlab.gnome.org";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "devdoc"
  ];

  postPatch = ''
    patchShebangs \
      data/meson_desktopfile.py \
      gucharmap/gen-guch-unicode-tables.pl
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook3
    unzip
    intltool
    itstool
    gtk-doc
    docbook_xsl
    docbook_xml_dtd_45
    yelp-tools
    libxml2
    desktop-file-utils
    gobject-introspection
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    gtk3
    glib
    gsettings-desktop-schemas
    pcre2
  ];

  mesonFlags = [
    "-Ducd_path=${ucd}/share/unicode"
    "-Dvapi=false"
  ];

  doCheck = true;

  passthru = {
    updateScript = gitUpdater {
    };
  };

  meta = {
    description = "GNOME Character Map, based on the Unicode Character Database";
    homepage = "https://gitlab.gnome.org/GNOME/gucharmap";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gucharmap";
    teams = [ lib.teams.gnome ];
  };
})
