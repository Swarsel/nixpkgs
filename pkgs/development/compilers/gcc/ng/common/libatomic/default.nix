{
  lib,
  stdenv,
  autoreconfHook269,
  fetchpatch,
  gcc_meta,
  getVersionFile,
  release_version,
  runCommand,
  version,
  monorepoSrc ? null,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "libatomic";

  src = runCommand "libatomic-src-${version}" { src = monorepoSrc; } ''
    runPhase unpackPhase

    mkdir -p "$out/gcc"
    cp gcc/BASE-VER "$out/gcc"
    cp gcc/DATESTAMP "$out/gcc"

    cp -r libatomic "$out"

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

  patches = [
    (fetchpatch {
      hash = "sha256-U1Eh6ByhmseHQigfHIyO4MlAQB3fECmpPEP/M00DOg0=";

      includes = [
        "config/*"
        "libatomic/configure.ac"
      ];

      name = "custom-threading-model.patch";
      url = "https://github.com/gcc-mirror/gcc/commit/e5d853bbe9b05d6a00d98ad236f01937303e40c4.diff";
    })
    (getVersionFile "libatomic/gthr-include.patch")
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
    sourceRoot=$(readlink -e "./libatomic")
    cd $sourceRoot
  '';

  passthru = {
    isGNU = true;
  };

  meta = gcc_meta // {
    homepage = "https://gcc.gnu.org/";
  };
})
