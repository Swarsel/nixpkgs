{
  lib,
  stdenv,
  fetchurl,
  imagemagick,
  libpng,
}:

stdenv.mkDerivation {
  pname = "optar";
  version = "20150210";

  src = fetchurl {
    url = "https://ronja.twibright.com/optar.tgz";
    sha256 = "10lr31k3xfcpa6vxkbl3abph7j3gks2210489khnnzmhmfdnm1a4";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace /usr/local $out

    substituteInPlace pgm2ps \
      --replace 'convert ' "${lib.getBin imagemagick}/bin/convert "
  '';

  buildInputs = [ libpng ];
  env.NIX_CFLAGS_COMPILE = toString [ "-Wno-error=implicit-int" ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  enableParallelBuilding = true;

  meta = {
    description = "OPTical ARchiver - it's a codec for encoding data on paper";
    homepage = "http://ronja.twibright.com/optar/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = with lib.platforms; linux; # possibly others, but only tested on Linux
  };
}
