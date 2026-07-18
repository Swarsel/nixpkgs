{
  lib,
  stdenv,
  fetchurl,
  exiv2,
  gi-docgen,
  glib,
  gobject-introspection,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  python3,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gexiv2";
  version = "0.16.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gexiv2/${lib.versions.majorMinor finalAttrs.version}/gexiv2-${finalAttrs.version}.tar.xz";
    sha256 = "2W+JXyRTn5ZvV3srskia6E+CMpcKjQwGTkoAdHSne7s=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    vala
    gi-docgen
    (python3.pythonOnBuildForHost.withPackages (ps: [ ps.pygobject3 ]))
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    glib
  ];

  propagatedBuildInputs = [
    exiv2
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
    "-Dtests=true"
  ];

  doCheck = true;

  preCheck =
    let
      libName = if stdenv.hostPlatform.isDarwin then "libgexiv2-0.16.4.dylib" else "libgexiv2-0.16.so.4";
    in
    ''
      # Our gobject-introspection patches make the shared library paths absolute
      # in the GIR files. When running unit tests, the library is not yet installed,
      # though, so we need to replace the absolute path with a local one during build.
      # We are using a symlink that will be overridden during installation.
      mkdir -p $out/lib
      ln -s $PWD/gexiv2/${libName} $out/lib/${libName}
      export GI_TYPELIB_PATH=$PWD/gexiv2
    '';

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  __structuredAttrs = true;

  depsBuildBuild = [
    pkg-config
  ];

  meta = {
    description = "GObject wrapper around the Exiv2 photo metadata library";
    homepage = "https://gitlab.gnome.org/GNOME/gexiv2";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers._7591yj ];
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
