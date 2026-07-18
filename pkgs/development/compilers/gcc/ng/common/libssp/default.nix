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
  pname = "libssp";

  src = runCommand "libssp-src-${version}" { src = monorepoSrc; } ''
    runPhase unpackPhase

    mkdir -p "$out/gcc"
    cp gcc/BASE-VER "$out/gcc"
    cp gcc/DATESTAMP "$out/gcc"

    cp -r libssp "$out"

    cp -r config "$out"
    cp -r multilib.am "$out"

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

  patches = [
    (fetchpatch {
      hash = "sha256-W7dcy1Tm3O2reK7kx83DRv8W97qUfaqDbKLiLXIegRw=";
      name = "regular-libdir-includedir.patch";
      url = "https://inbox.sourceware.org/gcc-patches/20250720172933.2404828-1-git@JohnEricson.me/raw";
    })
    (getVersionFile "libssp/force-regular-dirs.patch")
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

  hardeningDisable = [
    "fortify"
    # Because we are building it!
    "stackprotector"
  ];

  postUnpack = ''
    mkdir -p ./build
    buildRoot=$(readlink -e "./build")
  '';

  preAutoreconf = ''
    sourceRoot=$(readlink -e "./libssp")
    cd $sourceRoot
  '';

  passthru = {
    isGNU = true;
  };

  meta = gcc_meta // {
    homepage = "https://gcc.gnu.org/";
  };
})
