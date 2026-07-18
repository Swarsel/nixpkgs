{
  lib,
  stdenv,
  fetchurl,
  docbook-xsl-nons,
  docbook_xml_dtd_412,
  gnome,
  gtk-doc,
  meson,
  nautilus,
  ninja,
  pkg-config,
  python3,
  replaceVars,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nautilus-python";
  version = "4.1.0";

  src = fetchurl {
    url = "mirror://gnome/sources/nautilus-python/${lib.versions.majorMinor finalAttrs.version}/nautilus-python-${finalAttrs.version}.tar.xz";
    hash = "sha256-/EpEi8yxoJtohlQJueKu0XHSii1ayA975E9fzKhO4ME=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
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
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_412
    python3.pythonOnBuildForHost
  ];

  buildInputs = [
    python3
    python3.pkgs.pygobject3
    nautilus
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "nautilus-python";
    };
  };

  meta = {
    description = "Python bindings for the Nautilus Extension API";
    homepage = "https://gitlab.gnome.org/GNOME/nautilus-python";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
