{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  sourceSha256 ? "051mv6f13c8y13c1iv3279k1hhzpz4fm9sfczhgp9sim2bjdj055",
  version ? "1.7.1",
}:
stdenv.mkDerivation {
  inherit version;
  pname = "pmidi";

  src = fetchurl {
    url = "mirror://sourceforge/pmidi/${version}/pmidi-${version}.tar.gz";
    sha256 = sourceSha256;
  };

  buildInputs = [ alsa-lib ];

  meta = {
    description = "Straightforward command line program to play midi files through the ALSA sequencer";
    homepage = "https://www.parabola.me.uk/alsa/pmidi.html";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    mainProgram = "pmidi";
  };
}
