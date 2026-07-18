{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  tinycmmc,
}:

stdenv.mkDerivation {
  pname = "uitest";
  version = "0-unstable-2024-05-26";

  src = fetchFromGitHub {
    owner = "Grumbel";
    repo = "uitest";
    rev = "d845427140cbcbce99bb6c72919199ac5f033784";
    sha256 = "sha256-xD2Ecs9hW3lcQW6RNcjVhGX/eor2RbCHHXohTafC9y0=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.0)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ tinycmmc ];

  meta = {
    description = "Simple testing framework for interactive tests";
    homepage = "https://github.com/Grumbel/uitest";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.SchweGELBin ];
    platforms = lib.platforms.linux;
  };
}
