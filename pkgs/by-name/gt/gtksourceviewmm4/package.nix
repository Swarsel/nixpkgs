{
  lib,
  stdenv,
  fetchurl,
  glibmm,
  gnome,
  gtkmm3,
  gtksourceview4,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtksourceviewmm";
  version = "3.91.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gtksourceviewmm/${lib.versions.majorMinor finalAttrs.version}/gtksourceviewmm-${finalAttrs.version}.tar.xz";
    sha256 = "088p2ch1b4fvzl9416nw3waj0pqgp31cd5zj4lx5hzzrq2afgapy";
  };

  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs = [
    glibmm
    gtkmm3
    gtksourceview4
  ];

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "gtksourceviewmm4";
      packageName = "gtksourceviewmm";
      versionPolicy = "none";
    };
  };

  meta = {
    description = "C++ wrapper for gtksourceview";
    homepage = "https://gitlab.gnome.org/GNOME/gtksourceviewmm";
    license = lib.licenses.lgpl2;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})
