{
  lib,
  stdenv,
  fetchFromGitHub,
  # buildInputs
  SDL2,
  boost,
  bullet,
  # nativeBuildInputs
  cmake,
  ffmpeg_6,
  glm,
  libGL,
  libGLU,
  libmad,
  libx11,
  ninja,
  openal,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "openrw";
  version = "0-unstable-2025-06-18";

  src = fetchFromGitHub {
    owner = "rwengine";
    repo = "openrw";
    rev = "5c5f266b71aa55aeec8cb4d823f19e7c4348f3bd";
    hash = "sha256-2fQQL0JoV8YukU+VW2iWS4DpBi1j361SfiXRHRmocRg=";
    fetchSubmodules = true;
  };

  postPatch =
    lib.optionalString (stdenv.cc.isClang && (lib.versionAtLeast stdenv.cc.version "9")) ''
      substituteInPlace cmake_configure.cmake \
        --replace-fail 'target_link_libraries(rw_interface INTERFACE "stdc++fs")' ""
    ''
    + ''
      # boost 1.89 removed the boost_system stub library
      substituteInPlace CMakeLists.txt --replace-fail \
        'find_package(Boost COMPONENTS program_options system REQUIRED)' \
        'find_package(Boost COMPONENTS program_options REQUIRED)'
    '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    SDL2
    boost
    bullet
    ffmpeg_6
    glm
    libGL
    libGLU
    libmad
    libx11
    openal
  ];

  passthru = {
    updateScript = unstableGitUpdater { };
  };

  meta = {
    description = "Unofficial open source recreation of the classic Grand Theft Auto III game executable";

    longDescription = ''
      OpenRW is an open source re-implementation of Rockstar Games' Grand Theft
      Auto III, a classic 3D action game first published in 2001.
    '';

    homepage = "https://github.com/rwengine/openrw";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ kragniz ];
    platforms = lib.platforms.all;

    badPlatforms = [
      # error: implicit instantiation of undefined template 'std::char_traits<unsigned short>'
      lib.systems.inspect.patterns.isDarwin
    ];

    mainProgram = "rwgame";
  };
}
