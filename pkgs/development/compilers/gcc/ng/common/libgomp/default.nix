{
  lib,
  stdenv,
  autoreconfHook269,
  gcc_meta,
  getVersionFile,
  release_version,
  runCommand,
  version,
  monorepoSrc ? null,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "libgomp";

  src = runCommand "libgomp-src-${version}" { src = monorepoSrc; } ''
    runPhase unpackPhase

    mkdir -p "$out/gcc"
    cp gcc/BASE-VER "$out/gcc"
    cp gcc/DATESTAMP "$out/gcc"

    cp -r libgomp "$out"
    cp -r include "$out"

    cp -r config "$out"
    cp -r multilib.am "$out"
    cp -r libtool.m4 "$out"

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

  nativeBuildInputs = [
    autoreconfHook269
  ];

  configureFlags = [
    "--disable-dependency-tracking"
    "cross_compiling=true"
    "--disable-multilib"
  ];

  preConfigure = ''
    cd "$buildRoot"
    configureScript=$sourceRoot/configure
  '';

  doCheck = true;

  configurePlatforms = [
    "build"
    "host"
  ];

  enableParallelBuilding = true;

  postUnpack = ''
    mkdir -p ./build
    buildRoot=$(readlink -e "./build")
  '';

  preAutoreconf = ''
    sourceRoot=$(readlink -e "./libgomp")
    cd $sourceRoot
  '';

  passthru = {
    isGNU = true;
  };

  meta = gcc_meta // {
    homepage = "https://gcc.gnu.org/";
  };
})
