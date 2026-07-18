{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  dbus,
  glib,
  gobject-introspection,
  libsysprof-capture,
  libxml2,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  readline,
  spidermonkey_140,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cjs";
  version = "140.0";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "cjs";
    tag = finalAttrs.version;
    hash = "sha256-zbYcKzTuDLnFEVeSXgoZDUK8Wx3gysGSqZyXjKrBStI=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    patchShebangs --build build/choose-tests-locale.sh
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    which # for locale detection
    libxml2 # for xml-stripblanks
    dbus # for dbus-run-session
    gobject-introspection
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    cairo
    readline
    libsysprof-capture
    spidermonkey_140
  ];

  propagatedBuildInputs = [
    glib
  ];

  mesonFlags = [
    # This is just a copy of gjs so we don't run tests here.
    "-Dskip_gtk_tests=true"
  ]
  ++ lib.optionals stdenv.hostPlatform.isMusl [
    "-Dprofiler=disabled"
  ];

  meta = {
    description = "JavaScript bindings for Cinnamon";

    longDescription = ''
      This module contains JavaScript bindings based on gobject-introspection.
    '';

    homepage = "https://github.com/linuxmint/cjs";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
      mit
      mpl11
    ];

    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})
