{
  lib,
  stdenv,
  fetchFromGitLab,
  check,
  docbook_xml_dtd_43,
  docbook_xsl,
  gitUpdater,
  glib,
  glibcLocales,
  gobject-introspection,
  gtk-doc,
  libxml2,
  libxslt,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  python3,
  sqlite,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libaccounts-glib";
  version = "1.27";

  src = fetchFromGitLab {
    owner = "accounts-sso";
    repo = "libaccounts-glib";
    rev = "VERSION_${finalAttrs.version}";
    hash = "sha256-mLhcwp8rhCGSB1K6rTWT0tuiINzgwULwXINfCbgPKEg=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
    "py"
  ];

  # TODO: send patch upstream to make running tests optional
  postPatch = lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    substituteInPlace meson.build \
      --replace "subdir('tests')" ""
  '';

  nativeBuildInputs = [
    check
    docbook_xml_dtd_43
    docbook_xsl
    glibcLocales
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
    glib
    libxml2
    libxslt
    python3.pkgs.pygobject3
    sqlite
  ];

  mesonFlags = [
    "-Dinstall-py-overrides=true"
    "-Dpy-overrides-dir=${placeholder "py"}/${python3.sitePackages}/gi/overrides"
  ];

  env.LC_ALL = "en_US.UTF-8";

  passthru.updateScript = gitUpdater {
    rev-prefix = "VERSION_";
  };

  meta = {
    description = "Library for managing accounts which can be used from GLib applications";
    homepage = "https://gitlab.com/accounts-sso/libaccounts-glib";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.linux;
  };
})
