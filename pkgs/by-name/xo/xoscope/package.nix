{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  comedilib,
  fftw,
  gnum4,
  gtk3,
  gtkdatabox,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xoscope";
  version = "2.3";

  src = fetchurl {
    url = "mirror://sourceforge/xoscope/xoscope-${finalAttrs.version}.tar.gz";
    sha256 = "0a5ycfc1qdmibvagc82r2mhv2i99m6pndy5i6ixas3j2297g6pgq";
  };

  patches = [ ./fix-gcc14.patch ];

  nativeBuildInputs = [
    pkg-config
    gnum4
  ];

  buildInputs = [
    gtk3
    gtkdatabox
    fftw
    comedilib
    alsa-lib
  ];

  meta = {
    description = "Oscilloscope through the sound card";
    homepage = "https://xoscope.sourceforge.net";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "xoscope";
  };
})
