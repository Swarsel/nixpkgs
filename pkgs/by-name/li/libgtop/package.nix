{
  lib,
  stdenv,
  fetchurl,
  deterministic-uname,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gtk-doc,
  perl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgtop";
  version = "2.41.3";

  src = fetchurl {
    url = "mirror://gnome/sources/libgtop/${lib.versions.majorMinor finalAttrs.version}/libgtop-${finalAttrs.version}.tar.xz";
    hash = "sha256-d1Z235WOLqJFL3Vo8osupYEGPTEnc91cC3Ykwbmy2ow=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    # uname output embedded in https://gitlab.gnome.org/GNOME/libgtop/-/blob/master/src/daemon/Makefile.am
    deterministic-uname
    pkg-config
    gtk-doc
    perl
    gettext
    gobject-introspection
  ];

  propagatedBuildInputs = [
    glib
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "libgtop";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Library that reads information about processes and the running system";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
