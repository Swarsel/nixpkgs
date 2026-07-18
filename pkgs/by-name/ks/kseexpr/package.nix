{
  lib,
  stdenv,
  fetchFromGitLab,
  bison,
  cmake,
  flex,
  kdePackages,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kseexpr";
  version = "6.0.0.0";

  src = fetchFromGitLab {
    owner = "graphics";
    repo = "kseexpr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Z3CjQdKHeZ/6He43qVYQj8Fo0y88v/ldJJD8bPYOaEo=";
    domain = "invent.kde.org";
  };

  patches = [
    # see https://github.com/NixOS/nixpkgs/issues/144170
    ./cmake_libdir.patch
  ];

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
  ];

  buildInputs = [
    bison
    flex
    kdePackages.ki18n
    qt6.qtbase
    qt6.qttools
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Embeddable expression evaluation engine";
    homepage = "https://invent.kde.org/graphics/kseexpr";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
  };
})
