{
  lib,
  stdenv,
  fetchFromGitLab,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  glib,
  gobject-introspection,
  gtk-doc,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libqrtr-glib";
  version = "1.2.2";

  src = fetchFromGitLab {
    owner = "mobile-broadband";
    repo = "libqrtr-glib";
    rev = finalAttrs.version;
    sha256 = "kHLrOXN6wgBrHqipo2KfAM5YejS0/bp7ziBSpt0s1i0=";
    domain = "gitlab.freedesktop.org";
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
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    glib
  ];

  depsBuildBuild = [
    pkg-config
  ];

  meta = {
    description = "Qualcomm IPC Router protocol helper library";
    homepage = "https://gitlab.freedesktop.org/mobile-broadband/libqrtr-glib";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.freedesktop ];
  };
})
