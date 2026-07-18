{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxext,
  libxrandr,
  libxrender,
  xorgproto,
  patches ? [ ],
}:

stdenv.mkDerivation rec {
  # Allow users set their own list of patches
  inherit patches;
  pname = "evilwm";
  version = "1.5";

  src = fetchurl {
    url = "https://www.6809.org.uk/evilwm/evilwm-${version}.tar.gz";
    sha256 = "sha256-YQSFJBPm1QZpNh3K3aWiXTnisrDJWmOEAiyQWVeidA8=";
  };

  postPatch = ''
    substituteInPlace ./Makefile \
      --replace /usr $out \
      --replace "CC = gcc" "#CC = gcc"
  '';

  buildInputs = [
    libx11
    libxext
    libxrandr
    libxrender
    xorgproto
  ];

  meta = {
    description = "Minimalist window manager for the X Window System";
    homepage = "http://www.6809.org.uk/evilwm/";

    license = {
      free = true;
      fullName = "Custom, inherited from aewm and 9wm";
      shortName = "evilwm";
      url = "https://www.6809.org.uk/evilwm/";
    }; # like BSD/MIT, but Share-Alike'y; See README.

    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "evilwm";
  };
}
