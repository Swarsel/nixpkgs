{
  lib,
  stdenv,
  fetchurl,
  glib,
  gnome,
  gobject-introspection,
  libcanberra,
  libtool,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation rec {
  pname = "gsound";
  version = "1.0.3";

  src = fetchurl {
    url = "mirror://gnome/sources/gsound/${lib.versions.majorMinor version}/gsound-${version}.tar.xz";
    sha256 = "06l80xgykj7x1kqkjvcq06pwj2rmca458zvs053qc55x3sg06bfa";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gobject-introspection
    libtool
    vala
  ];

  buildInputs = [
    glib
    libcanberra
  ];

  depsBuildBuild = [ pkg-config ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Small library for playing system sounds";
    homepage = "https://gitlab.gnome.org/GNOME/gsound";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    mainProgram = "gsound-play";
    teams = [ lib.teams.gnome ];
  };
}
