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
  pname = "libiberty";

  src = runCommand "libiberty-src-${version}" { src = monorepoSrc; } ''
    runPhase unpackPhase

    mkdir -p "$out/gcc"
    cp gcc/BASE-VER "$out/gcc"
    cp gcc/DATESTAMP "$out/gcc"

    cp -r include "$out"
    cp -r libiberty "$out"

    cp config.guess "$out"
    cp config.rpath "$out"
    cp config.sub "$out"
    cp config-ml.in "$out"
    cp ltmain.sh "$out"
    cp install-sh "$out"
    cp mkinstalldirs "$out"

    [[ -f MD5SUMS ]]; cp MD5SUMS "$out"
  '';

  outputs = [
    "out"
    "dev"
  ];

  configureFlags = [
    "--enable-install-libiberty"
  ]
  ++ lib.optional (!stdenv.hostPlatform.isStatic) "--enable-shared";

  preConfigure = ''
    mkdir ../../build
    cd ../../build
    configureScript=../$sourceRoot/configure
  '';

  doCheck = true;

  postInstall = ''
    cp pic/libiberty.a $out/lib/libiberty_pic.a
  '';

  enableParallelBuilding = true;
  sourceRoot = "${finalAttrs.src.name}/libiberty";

  passthru = {
    isGNU = true;
  };

  meta = gcc_meta // {
    homepage = "https://gcc.gnu.org/";
  };
})
