{
  lib,
  stdenv,
  fetchurl,
  SDL,
  alsa-lib,
  autoreconfHook,
  freeglut,
  jack2,
  libGL,
  libGLU,
  libjpeg,
  libsndfile,
  pkg-config,
  tcl,
  alsaSupport ? stdenv.hostPlatform.isLinux,
  # Audio backend — exactly one must be selected.
  # ALSA is the upstream-recommended Linux backend; JACK is used elsewhere.
  jackSupport ? !stdenv.hostPlatform.isLinux,
}:

assert lib.assertMsg (
  lib.count (x: x) [
    jackSupport
    alsaSupport
  ] == 1
) "din: exactly one audio backend must be selected (jackSupport or alsaSupport)";

stdenv.mkDerivation (finalAttrs: {
  pname = "din";
  version = "64.2";

  src = fetchurl {
    url = "https://dinisnoise.org/files/din-${finalAttrs.version}.tar.gz";
    hash = "sha256-YpaGOAVJmUMDkqvu9+fzW1RbNNSRO2Id8zg8DIblGXE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    libsndfile
    libjpeg
    SDL
    tcl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    freeglut
    libGL
    libGLU
  ]
  ++ lib.optionals jackSupport [ jack2 ]
  ++ lib.optionals alsaSupport [ alsa-lib ];

  # Pass the backend macro and linker flags via configure, matching the
  # upstream build scripts (o3-alsa / o3-jack).
  # On Darwin, add -framework flags for OpenGL, GLUT, and Cocoa (needed by SDLmain),
  # silence deprecation warnings, and link SDLmain (provides the main() wrapper for SDL apps on macOS).
  configureFlags =
    (
      if jackSupport then
        [
          "CXXFLAGS=-D__UNIX_JACK__${lib.optionalString stdenv.hostPlatform.isDarwin " -DGL_SILENCE_DEPRECATION"}"
        ]
      else
        [
          "CXXFLAGS=-D__LINUX_ALSA__${lib.optionalString stdenv.hostPlatform.isDarwin " -DGL_SILENCE_DEPRECATION"}"
        ]
    )
    ++ lib.optional jackSupport "LIBS=-ljack"
    ++ lib.optional alsaSupport "LIBS=-lasound"
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      "LDFLAGS=-framework OpenGL -framework GLUT -framework Cocoa -lSDLmain"
    ];

  # Makefile.am hard-codes /usr/include/tcl8.6 and unconditionally links
  # -lasound. Strip both so Nix controls all flags via configureFlags.
  # On Darwin, also strip -lGL and -lrt since OpenGL is provided as a framework
  # and real-time extensions are built into the system library.
  preConfigure = ''
    substituteInPlace src/Makefile.am \
      --replace-fail "-I /usr/include/tcl8.6" "-I${tcl}/include" \
      --replace-fail " -lasound" ""
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace src/Makefile.am \
      --replace-fail " -lGL" "" \
      --replace-fail " -lrt" ""
  '';

  __structuredAttrs = true;
  # Darwin binary should NOT be available on the public cache; always build from source.
  # https://dinisnoise.org/README/
  allowSubstitutes = !stdenv.hostPlatform.isDarwin;
  enableParallelBuilding = true;

  meta = {
    description = "Open source cross-platform sound synthesizer";

    longDescription = ''
      DIN Is Noise is a program for making sound, music and noise. Use bezier
      curves to edit waveforms, envelopes, modulators and FX components; use
      the keyboard (computer and MIDI) to trigger notes (or noise), use the
      mouse to sound like the theremin, create drones on microtones, launch,
      orbit and drag them around; bounce balls on walls to trigger notes in a
      mondrian inspired drawing and also make binaural beats. Supports MIDI
      input and scripting through TCL.
    '';

    homepage = "https://dinisnoise.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fraggerfox ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "din";
  };
})
