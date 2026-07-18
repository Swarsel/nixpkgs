{
  lib,
  stdenv,
  fetchFromGitHub,
  # The two audio backends:
  SDL2,
  cmake,
  jack2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "audiality2";
  version = "1.9.4";

  src = fetchFromGitHub {
    owner = "olofson";
    repo = "audiality2";
    rev = "v${finalAttrs.version}";
    sha256 = "0ipqna7a9mxqm0fl9ggwhbc7i9yxz3jfyi0w3dymjp40v7jw1n20";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      'cmake_minimum_required(VERSION 2.8)' \
      'cmake_minimum_required(VERSION 3.5)'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    SDL2
    jack2
  ];

  meta = {
    description = "Realtime scripted modular audio engine for video games and musical applications";
    homepage = "http://audiality.org";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
    mainProgram = "a2play";
  };
})
