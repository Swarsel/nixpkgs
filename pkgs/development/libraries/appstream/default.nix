{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  bash-completion,
  buildPackages,
  cairo,
  cmake,
  curl,
  docbook-xsl-ns,
  docbook_xml_dtd_45,
  gdk-pixbuf,
  gettext,
  glib,
  gobject-introspection,
  gperf,
  itstool,
  libblake3,
  libfyaml,
  librsvg,
  libstemmer,
  libxml2,
  libxmlb,
  libxslt,
  meson,
  mesonEmulatorHook,
  ninja,
  nixosTests,
  pango,
  pkg-config,
  replaceVars,
  systemd,
  testers,
  vala,
  xapian,
  xmlto,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "appstream";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "ximion";
    repo = "appstream";
    rev = "v${finalAttrs.version}";
    hash = "sha256-z9HmTYOjglki+ID7GPMf3jGLOAkxLqJd4+GsIR3W3u4=";
  };

  outputs = [
    "out"
    "dev"
    "installedTests"
  ];

  patches = [
    # Fix hardcoded paths
    (replaceVars ./fix-paths.patch {
      libstemmer_includedir = "${lib.getDev libstemmer}/include";
    })

    # Allow installing installed tests to a separate output.
    ./installed-tests-path.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
    gettext
    libxslt
    xmlto
    docbook-xsl-ns
    docbook_xml_dtd_45
    glib
    itstool
    gperf
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ]
  ++ lib.optionals (!lib.systems.equals stdenv.buildPlatform stdenv.hostPlatform) [
    appstream
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
    vala
  ];

  buildInputs = [
    libblake3
    libstemmer
    glib
    xapian
    libxml2
    libxmlb
    libfyaml
    curl
    cairo
    gdk-pixbuf
    pango
    librsvg
    bash-completion
  ]
  ++ lib.optionals withSystemd [
    systemd
  ];

  mesonFlags = [
    "-Dapidocs=false"
    "-Dc_args=-Wno-error=missing-include-dirs"
    "-Ddocs=false"
    "-Dvapi=true"
    "-Dinstalled_test_prefix=${placeholder "installedTests"}"
    "-Dcompose=true"
    (lib.mesonBool "gir" withIntrospection)
  ]
  ++ lib.optionals (!withSystemd) [
    "-Dsystemd=false"
  ];

  depsBuildBuild = [
    pkg-config
  ];

  passthru.tests = {
    installed-tests = nixosTests.installed-tests.appstream;

    pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Software metadata handling library";

    longDescription = ''
      AppStream is a cross-distro effort for building Software-Center applications
      and enhancing metadata provided by software components.  It provides
      specifications for meta-information which is shipped by upstream projects and
      can be consumed by other software.
    '';

    homepage = "https://www.freedesktop.org/wiki/Distributions/AppStream/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    mainProgram = "appstreamcli";
    pkgConfigModules = [ "appstream" ];
  };
})
