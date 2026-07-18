{
  lib,
  stdenv,
  fetchurl,
  gdk-pixbuf,
  glib,
  gnome,
  gobject-introspection,
  meson,
  ninja,
  pkg-config,
  python3,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gom";
  version = "0.5.6";

  src = fetchurl {
    url = "mirror://gnome/sources/gom/${lib.versions.majorMinor finalAttrs.version}/gom-${finalAttrs.version}.tar.xz";
    sha256 = "TXpeJoaYyOfkBgPjbp46K3YTOTHOG2N8ETYwFJG1TMM=";
  };

  outputs = [
    "out"
    "py"
  ];

  patches = [
    ./longer-stress-timeout.patch
  ];

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    sqlite
    python3.pkgs.pygobject3
  ];

  mesonFlags = [
    "-Dpygobject-override-dir=${placeholder "py"}/${python3.sitePackages}/gi/overrides"
  ];

  # Success is more likely on x86_64
  doCheck = stdenv.hostPlatform.isx86_64;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gom";
    };
  };

  meta = {
    description = "GObject to SQLite object mapper";
    homepage = "https://gitlab.gnome.org/GNOME/gom";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
