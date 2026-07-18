{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  cmake,
  flex,
  zlib,
}:

stdenv.mkDerivation {
  pname = "pbrt-v3";
  version = "2023-09-03";

  src = fetchFromGitHub {
    owner = "mmp";
    repo = "pbrt-v3";
    rev = "13d871faae88233b327d04cda24022b8bb0093ee";
    hash = "sha256-xg99l1o4MychQiOYkfsvD9vO0ysfmgQyaNaf8oqoWzk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    flex
    bison
    cmake
  ];

  buildInputs = [ zlib ];

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  meta = {
    description = "Renderer described in the third edition of the book 'Physically Based Rendering: From Theory To Implementation'";
    homepage = "https://pbrt.org/";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.juliendehos ];
    platforms = lib.platforms.linux;
    priority = 10;
  };
}
