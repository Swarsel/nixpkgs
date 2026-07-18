{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  cairo,
  clutter,
  clutter-gst,
  clutter-gtk,
  gdk-pixbuf,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pinpoint";
  version = "0.1.8";

  src = fetchurl {
    url = "https://ftp.gnome.org/pub/GNOME/sources/pinpoint/0.1/pinpoint-${finalAttrs.version}.tar.xz";
    sha256 = "1jp8chr9vjlpb5lybwp5cg6g90ak5jdzz9baiqkbg0anlg8ps82s";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
  ];

  buildInputs = [
    clutter
    clutter-gst
    gdk-pixbuf
    cairo
    clutter-gtk
  ];

  meta = {
    description = "Tool for making hackers do excellent presentations";
    homepage = "https://gitlab.gnome.org/Archive/pinpoint";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux;
    mainProgram = "pinpoint";
  };
})
