{
  lib,
  stdenv,
  cmake,
  ninja,
}:

stdenv.mkDerivation {
  pname = "hello-cpp";
  version = lib.trivial.release;
  src = ./src;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  meta = {
    description = "Basic sanity check that C++ and cmake infrastructure are working";
    maintainers = stdenv.meta.maintainers or [ ];
    platforms = lib.platforms.all;
    mainProgram = "hello-cpp";
  };
}
