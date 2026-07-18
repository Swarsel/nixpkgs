{
  lib,
  stdenv,
  fetchurl,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gtk-doc,
  gtk3,
  liboauth,
  libsoup_3,
  libxml2,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  python3,
  totem-pl-parser,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "grilo";
  version = "0.3.19"; # if you change minor, also change ./setup-hook.sh

  src = fetchurl {
    url = "mirror://gnome/sources/grilo/${lib.versions.majorMinor finalAttrs.version}/grilo-${finalAttrs.version}.tar.xz";
    sha256 = "CGnIHRmrE5xmfXlWfBTdy2y1y/wBCNBMreKH6ylTZwY=";
  };

  outputs = [
    "out"
    "dev"
    "man"
    "devdoc"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    gettext
    gobject-introspection
    vala
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    glib
    liboauth
    gtk3
    libxml2
    libsoup_3
    totem-pl-parser
  ];

  mesonFlags = [
    "-Denable-gtk-doc=true"
  ];

  outputBin = "dev";
  setupHook = ./setup-hook.sh;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "grilo";
      versionPolicy = "none";
    };
  };

  meta = {
    description = "Framework that provides access to various sources of multimedia content, using a pluggable system";
    homepage = "https://gitlab.gnome.org/GNOME/grilo";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
