{
  lib,
  stdenv,
  fetchurl,
}:
let
  isCross = stdenv.buildPlatform != stdenv.hostPlatform;
  cross = "${stdenv.hostPlatform.config}";
  static = stdenv.hostPlatform.isStatic;

  cc = if !isCross then "cc" else "${cross}-cc";
  ar = if !isCross then "ar" else "${cross}-ar";
  ranlib = if !isCross then "ranlib" else "${cross}-ranlib";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "tinycdb";
  version = "0.81";

  src = fetchurl {
    url = "https://www.corpit.ru/mjt/tinycdb/tinycdb-${finalAttrs.version}.tar.gz";
    hash = "sha256-Rp3i1EW/VIgPZS9LbclcfN9vVQLDVSSkWyEi1w1H68I=";
  };

  # In general, static library (.a) goes to "dev", shared (.so) to
  # "lib". In case of static build, there is no .so library, so "lib"
  # output is useless and empty.
  outputs = [
    "out"
    "dev"
    "man"
  ]
  ++ lib.optional (!static) "lib";

  postPatch = ''
    sed -i 's,set --, set -x; set --,' Makefile
  '';

  makeFlags = [
    "prefix=$(out)"
    "CC=${cc}"
    "AR=${ar}"
    "RANLIB=${ranlib}"
    "static"
  ]
  ++ lib.optional (!static) "shared";

  postInstall = ''
    mkdir -p $dev/lib $out/bin
    mv $out/lib/libcdb.a $dev/lib
    rm --recursive $out/lib
  ''
  + (
    if static then
      ''
        cp cdb $out/bin/cdb
      ''
    else
      ''
        mkdir -p $lib/lib
        cp libcdb.so* $lib/lib
        cp cdb-shared $out/bin/cdb
      ''
  );

  separateDebugInfo = true;

  meta = {

    description = "Utility to manipulate constant databases (cdb)";

    longDescription = ''
      tinycdb is a small, fast and reliable utility and subroutine
      library for creating and reading constant databases. The database
      structure is tuned for fast reading.
    '';

    homepage = "https://www.corpit.ru/mjt/tinycdb.html";
    license = lib.licenses.publicDomain;
    platforms = lib.platforms.linux;
    mainProgram = "cdb";
  };
})
