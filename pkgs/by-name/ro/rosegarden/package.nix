{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  cmake,
  dssi,
  fftwSinglePrec,
  flac,
  glib,
  ladspa-header,
  ladspaPlugins,
  libjack2,
  liblo,
  libmpg123,
  libogg,
  libopus,
  libsamplerate,
  libsndfile,
  libsysprof-capture,
  libvorbis,
  lilv,
  lirc,
  lrdf,
  lv2,
  makedepend,
  perl,
  pkg-config,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rosegarden";
  version = "25.06";

  src = fetchurl {
    url = "mirror://sourceforge/rosegarden/rosegarden-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-df5SsAWJlHHMSw5JVL5dNe4c6PQWWauO9IomF4qlw20=";
  };

  nativeBuildInputs = [
    cmake
    makedepend
    perl
    pkg-config
    qt5.qttools
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    dssi
    fftwSinglePrec
    flac
    glib
    ladspa-header
    ladspaPlugins
    libjack2
    liblo
    libmpg123
    libogg
    libopus
    libsamplerate
    libsndfile
    libsysprof-capture
    libvorbis
    lilv
    lv2
    lirc
    lrdf
    qt5.qtbase
  ];

  cmakeFlags = [
    "-DLILV_INCLUDE_DIR=${lilv.dev}/include/lilv-0"
  ];

  postPhase = ''
    substituteInPlace src/CMakeLists.txt --replace svnheader svnversion
  '';

  meta = {
    description = "Music composition and editing environment";

    longDescription = ''
      Rosegarden is a music composition and editing environment based around
      a MIDI sequencer that features a rich understanding of music notation
      and includes basic support for digital audio.

      Rosegarden is an easy-to-learn, attractive application that runs on Linux,
      ideal for composers, musicians, music students, and small studio or home
      recording environments.
    '';

    homepage = "https://www.rosegardenmusic.com/";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ lebastr ];
    platforms = lib.platforms.linux;
    mainProgram = "rosegarden";
  };
})
