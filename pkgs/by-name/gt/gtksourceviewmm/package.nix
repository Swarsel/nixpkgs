{
  lib,
  stdenv,
  fetchurl,
  glibmm,
  gnome,
  gtkmm3,
  gtksourceview3,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtksourceviewmm";
  version = "3.21.3";

  src = fetchurl {
    url = "mirror://gnome/sources/gtksourceviewmm/${lib.versions.majorMinor finalAttrs.version}/gtksourceviewmm-${finalAttrs.version}.tar.xz";
    sha256 = "1danc9mp5mnb65j01qxkwj92z8jf1gns41wbgp17qh7050f0pc6v";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glibmm
    gtkmm3
    gtksourceview3
  ];

  passthru = {
    updateScript = gnome.updateScript {
      freeze = true;
      packageName = "gtksourceviewmm";
      versionPolicy = "none";
    };
  };

  meta = {
    description = "C++ wrapper for gtksourceview";
    homepage = "https://gitlab.gnome.org/GNOME/gtksourceviewmm";
    license = lib.licenses.lgpl2;
    maintainers = [ lib.maintainers.juliendehos ];
    platforms = lib.platforms.unix;
  };
})
