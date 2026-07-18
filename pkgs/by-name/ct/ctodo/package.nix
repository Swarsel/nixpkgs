{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ncurses,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ctodo";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "nielssp";
    repo = "ctodo";
    rev = "v${finalAttrs.version}";
    sha256 = "0mqy5b35cbdwfpbs91ilsgz3wc4cky38xfz9pnr4q88q1vybigna";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      'cmake_minimum_required(VERSION 2.6)' \
      'cmake_minimum_required(VERSION 3.5)'
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    ncurses
    readline
  ];

  meta = {
    description = "Simple ncurses-based task list manager";
    homepage = "http://ctodo.apakoh.dk/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.matthiasbeyer ];
    platforms = lib.platforms.unix;
    mainProgram = "ctodo";
  };
})
