{
  lib,
  stdenv,
  fetchurl,
  bison,
  flex,
  gettext,
  gi-docgen,
  glib,
  gnome,
  gobject-introspection,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "template-glib";
  version = "3.40.0";

  src = fetchurl {
    url = "mirror://gnome/sources/template-glib/${lib.versions.majorMinor finalAttrs.version}/template-glib-${finalAttrs.version}.tar.xz";
    hash = "sha256-5TPsL2wkzG32asVayCT63RtKX0M6EcvzprJYFcDPz9U=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    flex
    bison
    vala
    gi-docgen
    glib
    gobject-introspection
  ];

  buildInputs = [
    glib
  ];

  mesonFlags = [
    "-Ddocs=true"
  ];

  doCheck = true;

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput share/doc/template-glib-1.0 "$devdoc"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "template-glib";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Library for template expansion which supports calling into GObject Introspection from templates";
    homepage = "https://gitlab.gnome.org/GNOME/template-glib";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
