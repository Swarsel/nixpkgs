{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  libGL,
  libGLU,
  libjpeg_turbo,
  libpng,
  libuv,
  libvorbis,
  mbedtls,
  ninja,
  openal,
  sqlite,
}:

stdenv.mkDerivation rec {
  pname = "hashlink";
  version = "1.15";

  src = fetchFromGitHub {
    owner = "HaxeFoundation";
    repo = "hashlink";
    rev = version;
    sha256 = "sha256-nVr+fDdna8EEHvIiXsccWFRTYzXfb4GG1zrfL+O6zLA=";
  };

  # backport of https://github.com/HaxeFoundation/hashlink/pull/767
  postPatch = ''
    substituteInPlace CMakeLists.txt \
     --replace-warn \
       "cmake_minimum_required(VERSION 3.1)" \
       "cmake_minimum_required(VERSION 3.13)"
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libGL
    libGLU
    libjpeg_turbo
    libpng
    libuv
    libvorbis
    mbedtls
    openal
    SDL2
    sqlite
  ];

  # append default installPhase with library install for haxe
  postInstall =
    let
      haxelibPath = "$out/lib/haxe/hashlink/${lib.replaceStrings [ "." ] [ "," ] version}";
    in
    ''
      mkdir -p "${haxelibPath}"
      echo -n "${version}" > "${haxelibPath}/../.current"
      cp -r ../other/haxelib/* "${haxelibPath}"
    '';

  meta = {
    description = "Virtual machine for Haxe";
    homepage = "https://hashlink.haxe.org/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      iblech
      locallycompact
      logo
    ];

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "hl";
  };
}
