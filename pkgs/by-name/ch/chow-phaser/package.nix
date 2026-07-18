{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  at-spi2-core,
  cmake,
  curl,
  dbus,
  freetype,
  gcc-unwrapped,
  gtk3,
  libGL,
  libdatrie,
  libepoxy,
  libglut,
  libjack2,
  libpsl,
  libselinux,
  libsepol,
  libsysprof-capture,
  libthai,
  libxcursor,
  libxdmcp,
  libxext,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxtst,
  pkg-config,
  python3,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chow-phaser";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "jatinchowdhury18";
    repo = "ChowPhaser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9wo7ZFMruG3QNvlpILSvrFh/Sx6J1qnlWc8+aQyS4tQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    curl
    dbus
    libepoxy
    libglut
    freetype
    gtk3
    libGL
    libxcursor
    libxdmcp
    libxext
    libxinerama
    libxrandr
    libxtst
    libdatrie
    libjack2
    libpsl
    libselinux
    libsepol
    libsysprof-capture
    libthai
    libxkbcommon
    python3
    sqlite
    gcc-unwrapped
  ];

  cmakeFlags = [
    "-DCMAKE_AR=${gcc-unwrapped}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${gcc-unwrapped}/bin/gcc-ranlib"
    "-DCMAKE_NM=${gcc-unwrapped}/bin/gcc-nm"
  ];

  installPhase = ''
    mkdir -p $out/lib/lv2 $out/lib/vst3 $out/bin $out/share/doc/ChowPhaser/
    cd ChowPhaserMono_artefacts/Release
    cp libChowPhaserMono_SharedCode.a  $out/lib
    cp -r VST3/ChowPhaserMono.vst3 $out/lib/vst3
    cp Standalone/ChowPhaserMono  $out/bin
    cd ../../ChowPhaserStereo_artefacts/Release
    cp libChowPhaserStereo_SharedCode.a  $out/lib
    cp -r VST3/ChowPhaserStereo.vst3 $out/lib/vst3
    cp Standalone/ChowPhaserStereo  $out/bin
  '';

  meta = {
    description = "Phaser effect based loosely on the Schulte Compact Phasing 'A'";
    homepage = "https://github.com/jatinchowdhury18/ChowPhaser";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ magnetophon ];
    platforms = lib.platforms.linux;
    mainProgram = "ChowPhaserStereo";
  };
})
