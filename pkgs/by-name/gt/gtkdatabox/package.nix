{
  lib,
  stdenv,
  fetchurl,
  cairo,
  gtk3,
  pango,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtkdatabox";
  version = "1.0.0";

  src = fetchurl {
    url = "mirror://sourceforge/gtkdatabox/gtkdatabox-${finalAttrs.version}.tar.gz";
    sha256 = "1qykm551bx8j8pfgxs60l2vhpi8lv4r8va69zvn2594lchh71vlb";
  };

  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs = [
    gtk3
    pango
    cairo
  ];

  meta = {
    description = "GTK widget for displaying large amounts of numerical data";
    homepage = "https://gtkdatabox.sourceforge.io/";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ yl3dy ];
    platforms = lib.platforms.unix;
  };
})
