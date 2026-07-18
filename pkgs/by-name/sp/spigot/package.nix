{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  cmake,
  gmp,
  halibut,
  ncurses,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spigot";
  version = "20240909.f158e08";

  src = fetchurl {
    url = "https://www.chiark.greenend.org.uk/~sgtatham/spigot/spigot-${finalAttrs.version}.tar.gz";
    hash = "sha256-8re4ubDgsTjc/WrE60b6eXBrGEJSKJTEXd/XMdJ79nM=";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    halibut
    perl
  ];

  buildInputs = [
    gmp
    ncurses
  ];

  passthru.tests = {
    approximation = callPackage ./tests/approximation.nix {
      spigot = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Command-line exact real calculator";
    homepage = "https://www.chiark.greenend.org.uk/~sgtatham/spigot/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "spigot";
  };
})
