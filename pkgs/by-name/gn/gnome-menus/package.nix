{
  lib,
  stdenv,
  fetchurl,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "gnome-menus";
  version = "3.38.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-menus/${lib.versions.majorMinor version}/gnome-menus-${version}.tar.xz";
    sha256 = "EZipHNvc+yMt+U5x71QnYX0mAp4ye+P4YMOwkhxEgRg=";
  };

  nativeBuildInputs = [
    pkg-config
    gettext
    gobject-introspection
  ];

  buildInputs = [ glib ];

  makeFlags = [
    "INTROSPECTION_GIRDIR=${placeholder "out"}/share/gir-1.0/"
    "INTROSPECTION_TYPELIBDIR=${placeholder "out"}/lib/girepository-1.0"
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "none";
    };
  };

  meta = {
    description = "Library that implements freedesktops's Desktop Menu Specification in GNOME";
    homepage = "https://gitlab.gnome.org/GNOME/gnome-menus";

    license = with lib.licenses; [
      gpl2
      lgpl2
    ];

    platforms = lib.platforms.linux;
  };
}
