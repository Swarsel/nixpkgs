{
  lib,
  stdenv,
  fetchurl,
  carla,
  cmake,
  dbus,
  fftwFloat,
  file,
  freetype,
  jansson,
  libGL,
  libarchive,
  libglvnd,
  libjack2,
  liblo,
  libsamplerate,
  libsndfile,
  libx11,
  libxcursor,
  libxext,
  libxrandr,
  makeWrapper,
  pkg-config,
  python3,
  speexdsp,
  headless ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cardinal";
  version = "26.02";

  src = fetchurl {
    url = "https://github.com/DISTRHO/Cardinal/releases/download/${finalAttrs.version}/cardinal+deps-${finalAttrs.version}.tar.xz";
    hash = "sha256-4xjRCYN6Y7YtFc4gCd8F7CQxB02PLZQ6DN59rZVPYh0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    file
    pkg-config
    makeWrapper
    python3
  ];

  buildInputs = [
    dbus
    fftwFloat
    freetype
    jansson
    libGL
    libx11
    libxcursor
    libxext
    libxrandr
    libarchive
    liblo
    libsamplerate
    libsndfile
    speexdsp
    libglvnd
  ];

  makeFlags = [
    "SYSDEPS=true"
    "PREFIX=$(out)"
  ]
  ++ lib.optional (stdenv.hostPlatform != stdenv.buildPlatform) "CROSS_COMPILING=true"
  ++ lib.optional headless "HEADLESS=true";

  postInstall = ''
    wrapProgram $out/bin/Cardinal \
    --suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libjack2 ]}

    wrapProgram $out/bin/CardinalMini \
    --suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libjack2 ]}

    # this doesn't work and is mainly just a test tool for the developers anyway.
    rm -f $out/bin/CardinalNative
  '';

  dontUseCmakeConfigure = true;
  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];

  prePatch = ''
    patchShebangs ./dpf/utils/generate-ttl.sh

    substituteInPlace plugins/Cardinal/src/Carla.cpp \
      --replace-fail "/usr/lib/carla" "${carla}/bin" \
      --replace-fail "/usr/share/carla/resources" "${carla}/share"

    substituteInPlace plugins/Cardinal/src/Ildaeil.cpp \
      --replace-fail "/usr/lib/carla" "${carla}/bin" \
      --replace-fail "/usr/share/carla/resources" "${carla}/share"
  '';

  meta = {
    description = "Plugin wrapper around VCV Rack";
    homepage = "https://github.com/DISTRHO/cardinal";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      magnetophon
      PowerUser64
    ];

    platforms = lib.platforms.linux;
    mainProgram = "Cardinal";
  };
})
