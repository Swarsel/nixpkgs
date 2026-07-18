{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "enet";
  version = "1.3.18";

  src = fetchurl {
    url = "http://enet.bespin.org/download/enet-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-KooMU2DWi7T80R8uTEfGmXbo0shbEJ3X1gsRgaT4XTY=";
  };

  meta = {
    description = "Simple and robust network communication layer on top of UDP";
    homepage = "http://enet.bespin.org/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
