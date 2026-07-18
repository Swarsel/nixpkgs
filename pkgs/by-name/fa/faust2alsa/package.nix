{
  alsa-lib,
  atk,
  cairo,
  faust,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk2,
  pango,
}:

faust.wrapWithBuildEnv {

  propagatedBuildInputs = [
    alsa-lib
    atk
    cairo
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk2
    pango
  ];

  baseName = "faust2alsa";

}
