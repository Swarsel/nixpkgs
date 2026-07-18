{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  boost,
  bzip2,
  fetchpatch2,
  fftw,
  fftwFloat,
  libfishsound,
  libid3tag,
  libjack2,
  liblo,
  libmad,
  libogg,
  liboggz,
  libpulseaudio,
  libsForQt5,
  libsamplerate,
  libsndfile,
  libx11,
  lrdf,
  opusfile,
  pkg-config,
  rubberband,
  serd,
  sord,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tony";
  version = "2.1.1";

  src = fetchurl {
    url = "https://code.soundsoftware.ac.uk/attachments/download/2616/tony-${finalAttrs.version}.tar.gz";
    sha256 = "03g2bmlj08lmgvh54dyd635xccjn730g4wwlhpvsw04bffz8b7fp";
  };

  patches = [
    (fetchpatch2 {
      extraPrefix = "svcore/";
      hash = "sha256-DOCdQqCihkR0g/6m90DbJxw00QTpyVmFzCxagrVWKiI=";
      stripLen = 1;
      url = "https://github.com/sonic-visualiser/svcore/commit/5a7b517e43b7f0b3f03b7fc3145102cf4e5b0ffc.patch";
    })
    (fetchpatch2 {
      excludes = [ "svgui/widgets/CSVExportDialog.cpp" ];
      extraPrefix = "svgui/";
      hash = "sha256-pBCtoMXgjreUm/D0pl6+R9x1Ovwwwj8Ohv994oMX8XA=";
      stripLen = 1;
      url = "https://github.com/sonic-visualiser/svgui/commit/5b6417891cff5cc614e8c96664d68674eb12b191.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    boost
    bzip2
    fftw
    fftwFloat
    libx11
    libfishsound
    libid3tag
    libjack2
    liblo
    libmad
    libogg
    liboggz
    libpulseaudio
    libsamplerate
    libsndfile
    lrdf
    opusfile
    libsForQt5.qtbase
    libsForQt5.qtsvg
    rubberband
    serd
    sord
  ];

  # comment out the tests
  preConfigure = ''
    sed -i 's/sub_test_svcore_/#sub_test_svcore_/' tony.pro
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Pitch and note annotation of unaccompanied melody";
    homepage = "https://www.sonicvisualiser.org/tony/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "tony";
  };
})
