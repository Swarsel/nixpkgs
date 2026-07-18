{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  curl,
  fetchpatch,
  freetype,
  libGL,
  libGLU,
  libjack2,
  libx11,
  libxcomposite,
  libxcursor,
  libxext,
  libxinerama,
  libxrandr,
  libxrender,
  lv2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "helm";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "mtytel";
    repo = "helm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pI1umrJGMRBB3ifiWrInG7/Rwn+8j9f8iKkzC/cW2p8=";
  };

  patches = [
    # gcc9 compatibility https://github.com/mtytel/helm/pull/233
    (fetchpatch {
      hash = "sha256-s0eiE5RziZGdInSUOYWR7duvQnFmqf8HO+E7lnVCQsQ=";
      url = "https://github.com/mtytel/helm/commit/cb611a80bd5a36d31bfc31212ebbf79aa86c6f08.patch";
    })
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "usr/" ""

    substituteInPlace src/common/load_save.cpp \
      --replace-fail "/usr/share/" "$out/share/"

    substituteInPlace JUCE/modules/juce_audio_formats/codecs/flac/libFLAC/cpu.c \
      --replace-fail "__sigemptyset(&sigill_sse.sa_mask);" "sigemptyset(&sigill_sse.sa_mask);"
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxcomposite
    libxcursor
    libxext
    libxinerama
    libxrender
    libxrandr
    freetype
    alsa-lib
    curl
    libjack2
    libGLU
    libGL
    lv2
  ];

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  env.CXXFLAGS = toString [
    "-DHAVE_LROUND"
    "-fpermissive"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Free, cross-platform, polyphonic synthesizer";

    longDescription = ''
      A free, cross-platform, polyphonic synthesizer.
      Features:
        32 voice polyphony
        Interactive visual interface
        Powerful modulation system with live visual feedback
        Dual oscillators with cross modulation and up to 15 oscillators each
        Unison and Harmony mode for oscillators
        Oscillator feedback and saturation for waveshaping
        12 different waveforms
        7 filter types with keytracking
        2 monophonic and 1 polyphonic LFO
        Step sequencer
        Lots of modulation sources including polyphonic aftertouch
        Simple arpeggiator
        Effects: Formant filter, stutter, delay
    '';

    homepage = "https://tytel.org/helm";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      magnetophon
      bot-wxt1221
    ];

    platforms = lib.platforms.linux;
    mainProgram = "helm";
  };
})
