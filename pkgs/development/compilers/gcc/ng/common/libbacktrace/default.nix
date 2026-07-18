{
  lib,
  stdenv,
  gcc_meta,
  release_version,
  runCommand,
  version,
  monorepoSrc ? null,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "libbacktrace";

  src = runCommand "libbacktrace-src-${version}" { src = monorepoSrc; } ''
    runPhase unpackPhase

    mkdir -p "$out/gcc"
    cp gcc/BASE-VER "$out/gcc"
    cp gcc/DATESTAMP "$out/gcc"

    cp -r include "$out"
    cp -r libbacktrace "$out"

    cp config.guess "$out"
    cp config.rpath "$out"
    cp config.sub "$out"
    cp config-ml.in "$out"
    cp ltmain.sh "$out"
    cp install-sh "$out"
    cp move-if-change "$out"
    cp mkinstalldirs "$out"
    cp test-driver "$out"

    [[ -f MD5SUMS ]]; cp MD5SUMS "$out"
  '';

  outputs = [
    "out"
    "dev"
  ];

  preConfigure = ''
    mkdir ../../build
    cd ../../build
    configureScript=../$sourceRoot/configure
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # GNU debuglink is not supported on macOS (Mach-O format)
    # Skip the gnudebuglink tests which fail on Darwin
    export libbacktrace_cv_objcopy_debuglink=no
  '';

  doCheck = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib"
    cp .libs/*.a "$out/lib"
    cp libbacktrace*.la "$out/lib"

    mkdir -p "$dev/include"
    cp backtrace-supported.h "$dev/include"

    runHook postInstall
  '';

  enableParallelBuilding = true;
  sourceRoot = "${finalAttrs.src.name}/libbacktrace";

  passthru = {
    isGNU = true;
  };

  meta = gcc_meta // {
    homepage = "https://gcc.gnu.org/";
  };
})
