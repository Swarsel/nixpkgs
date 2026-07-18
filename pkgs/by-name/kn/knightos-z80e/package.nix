{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  knightos-scas,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "z80e";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "KnightOS";
    repo = "z80e";
    rev = finalAttrs.version;
    sha256 = "sha256-FQMYHxKxHEP+x98JbGyjaM0OL8QK/p3epsAWvQkv6bc=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8.5)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace libz80e/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace frontends/libz80e/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    readline
    SDL2
    knightos-scas
  ];

  cmakeFlags = [ "-Denable-sdl=YES" ];

  meta = {
    description = "Z80 calculator emulator and debugger";
    homepage = "https://knightos.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
  };
})
