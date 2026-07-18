{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gi-docgen,
  glib,
  gnome,
  gobject-introspection,
  gtk3,
  meson,
  ncurses,
  ninja,
  pkg-config,
  python3,
  replaceVars,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "libpeas";
  version = "1.38.1";

  src = fetchurl {
    url = "mirror://gnome/sources/libpeas/${lib.versions.majorMinor version}/libpeas-${version}.tar.xz";
    sha256 = "sha256-6C/TKK3KwaujS2QTa9/Lus8rMliovE5fSApyUCphGuk=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  patches = [
    # Make PyGObject’s gi library available.
    (replaceVars ./fix-paths.patch {
      pythonPaths = lib.concatMapStringsSep ", " (pkg: "'${pkg}/${python3.sitePackages}'") [
        python3.pkgs.pygobject3
      ];
    })
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gettext
    gi-docgen
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    ncurses
    python3
    python3.pkgs.pygobject3
  ];

  propagatedBuildInputs = [
    # Required by libpeas-1.0.pc
    gobject-introspection
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  depsBuildBuild = [
    pkg-config
  ];

  passthru = {
    updateScript = gnome.updateScript {
      freeze = true;
      packageName = "libpeas";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "GObject-based plugins engine";
    homepage = "https://gitlab.gnome.org/GNOME/libpeas";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "peas-demo";
    teams = [ lib.teams.gnome ];
  };
}
