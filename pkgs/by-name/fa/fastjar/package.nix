{
  lib,
  stdenv,
  callPackage,
  fetchzip,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fastjar";
  version = "0.98";

  src = fetchzip {
    inherit (finalAttrs) version;
    url = "mirror://savannah/fastjar/fastjar-${finalAttrs.version}.tar.gz";
    hash = "sha256-8VyKNQaPLrXAy/UEm2QkBx56SSSoLdU/7w4IwrxbsQc=";
    pname = "fastjar-source";
  };

  outputs = [
    "out"
    "info"
    "man"
  ];

  strictDeps = true;
  buildInputs = [ zlib ];
  doCheck = true;

  passthru = {
    tests = lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./tests;
    };
  };

  meta = {
    description = "Fast Java archiver written in C";

    longDescription = ''
      FastJar is an attempt at creating a feature-for-feature copy of Sun's
      JDK's 'jar' command.  Sun's jar (or Blackdown's for that matter) is
      written entirely in Java which makes it dog slow.  Since FastJar is
      written in C, it can create the same .jar file as Sun's tool in a fraction
      of the time.
    '';

    homepage = "https://savannah.nongnu.org/projects/fastjar/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "fastjar";
  };
})
