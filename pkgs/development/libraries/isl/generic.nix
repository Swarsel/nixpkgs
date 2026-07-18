{
  sha256,
  urls,
  version,
  configureFlags ? [ ],
  patches ? [ ],
}:

{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  buildPackages,
  gmp,
  updateAutotoolsGnuConfigScriptsHook,
}:

stdenv.mkDerivation {
  inherit version;
  inherit patches;
  inherit configureFlags;
  pname = "isl";

  src = fetchurl {
    inherit urls sha256;
  };

  strictDeps = true;

  nativeBuildInputs =
    lib.optionals (stdenv.hostPlatform.isRiscV && lib.versionOlder version "0.23") [
      autoreconfHook
    ]
    ++ [
      # needed until config scripts are updated to not use /usr/bin/uname on FreeBSD native
      updateAutotoolsGnuConfigScriptsHook
    ];

  buildInputs = [ gmp ];
  makeFlags = lib.optional stdenv.hostPlatform.isPE "LDFLAGS=-no-undefined";
  depsBuildBuild = lib.optionals (lib.versionAtLeast version "0.23") [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;

  meta = {
    description = "Library for manipulating sets and relations of integer points bounded by linear constraints";
    homepage = "https://libisl.sourceforge.io/";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.all;
  };
}
