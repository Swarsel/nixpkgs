{
  lib,
  stdenv,
  fetchFromGitHub,
  check,
  cmake,
  glib,
  libbsd,
  pcre,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rcon";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "n0la";
    repo = "rcon";
    rev = finalAttrs.version;
    sha256 = "sha256-bHm6JeWmpg42VZQXikHl+BMx9zimRLBQWemTqOxyLhw=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "CMAKE_MINIMUM_REQUIRED(VERSION 3.1)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace tests/CMakeLists.txt \
      --replace-fail "CMAKE_MINIMUM_REQUIRED(VERSION 3.0)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    glib
    libbsd
    check
    pcre
  ];

  meta = {
    description = "Source RCON client for command line";
    homepage = "https://github.com/n0la/rcon";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "rcon";
  };
})
