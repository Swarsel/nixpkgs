{
  lib,
  stdenv,
  fetchurl,
  glib,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ctpl";
  version = "0.3.5";

  src = fetchurl {
    url = "https://download.tuxfamily.org/ctpl/releases/ctpl-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-IRCPx1Z+0hbe6kWRrb/s6OiLH0uxynfDdACSBkTXVr4=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ glib ];

  meta = {
    description = "Template engine library written in C";
    homepage = "http://ctpl.tuxfamily.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "ctpl";
  };
})
