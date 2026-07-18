{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  aubio,
  boost,
  cmake,
  fetchpatch,
  ffmpeg,
  fmt,
  gettext,
  glew,
  glibmm,
  glm,
  icu,
  libepoxy,
  librsvg,
  libxmlxx,
  nlohmann_json,
  pango,
  pkg-config,
  portaudio,
}:

stdenv.mkDerivation rec {
  pname = "performous";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "performous";
    repo = "performous";
    tag = version;
    hash = "sha256-f70IHA8LqIlkMRwJqSmszx3keStSx50nKcEWLGEjc3g=";
  };

  patches = [
    ./performous-cmake.patch
    ./performous-fftw.patch
    (fetchpatch {
      excludes = [ ".github/workflows/macos.yml" ];
      hash = "sha256-cQVelET/g2Kx2PlV3pspjEoNIwwn5Yz6enYl5vCMMKo=";
      name = "performous-ffmpeg.patch";
      url = "https://github.com/performous/performous/commit/f26c27bf74b85fa3e3b150682ab9ecf9aecb3c50.patch";
    })
    (fetchpatch {
      hash = "sha256-98pcO/sFQJ+G67ErwlO/aAITNDPuRgPziQiF1cAlc0g=";
      name = "performous-gcc14.patch";
      url = "https://github.com/performous/performous/commit/eb9b97f46b7d064c32ed0f086d89a70427ce1d14.patch";
    })
    # Fix build with CMake 4
    (fetchpatch {
      extraPrefix = "ced-src/";
      hash = "sha256-23VD/4X4BOtcX5k+koSlRMowlbo2jAXbp3XKTXP7VrM=";
      stripLen = 1;
      url = "https://github.com/performous/compact_enc_det/commit/28f46c18c60b851773b0ff61f3ce416fb09adcf3.patch?full_index=1";
    })
    (fetchpatch {
      excludes = [ "osx-utils/macos-bundler.py" ];
      hash = "sha256-Srkjr8BI98N8Ws853goonvjOrEyWvzjHAIhypgEydns=";
      name = "performous-ffmpeg_8.patch";
      url = "https://github.com/performous/performous/commit/783befe576051458da7ea0d915d2b4cb986eaf86.patch";
    })
  ];

  postPatch = ''
    substituteInPlace data/CMakeLists.txt \
      --replace "/usr" "$out"
    substituteInPlace {game,testing}/CMakeLists.txt \
      --replace-fail "system locale" "locale"
  '';

  nativeBuildInputs = [
    cmake
    gettext
    pkg-config
  ];

  buildInputs = [
    SDL2
    aubio
    boost
    ffmpeg
    fmt
    glew
    glibmm
    glm
    icu
    libepoxy
    librsvg
    libxmlxx
    nlohmann_json
    pango
    portaudio
  ];

  cedSrc = fetchFromGitHub {
    hash = "sha256-ztfeblR4YnB5+lb+rwOQJjogl+C9vtPH9IVnYO7oxec=";
    owner = "performous";
    repo = "compact_enc_det";
    rev = "9ca1351fe0b1e85992a407b0fc54a63e9b3adc6e";
  };

  prePatch = ''
    mkdir ced-src
    cp -R ${cedSrc}/* ced-src
  '';

  meta = {
    description = "Karaoke, band and dancing game";
    homepage = "https://performous.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.linux;
    mainProgram = "performous";
  };
}
