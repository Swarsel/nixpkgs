{
  lib,
  stdenv,
  autoreconfHook269,
  fetchpatch,
  gcc_meta,
  getVersionFile,
  gettext,
  release_version,
  runCommand,
  version,
  monorepoSrc ? null,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "libstdcxx";

  src = runCommand "libstdcxx-src-${version}" { src = monorepoSrc; } ''
    runPhase unpackPhase

    mkdir -p "$out/gcc"
    cp gcc/BASE-VER "$out/gcc"
    cp gcc/DATESTAMP "$out/gcc"

    mkdir -p "$out/libgcc"
    cp libgcc/gthr*.h "$out/libgcc"
    cp libgcc/unwind-pe.h "$out/libgcc"

    cp -r libstdc++-v3 "$out"

    cp -r libiberty "$out"
    cp -r include "$out"
    cp -r contrib "$out"

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
      hash = "sha256-f0XAim3uzHnUx5lm/xO00IqBHu4YUEHF2WY+c0yCF6Y=";

      includes = [
        "config/*"
        "libstdc++-v3/acinclude.m4"
      ];

      name = "custom-threading-model.patch";
      url = "https://github.com/gcc-mirror/gcc/commit/e5d853bbe9b05d6a00d98ad236f01937303e40c4.diff";
    })
    (getVersionFile "libstdcxx/force-regular-dirs.patch")
  ];

  nativeBuildInputs = [
    autoreconfHook269
    gettext
  ];

  configureFlags = [
    "--disable-dependency-tracking"
    "gcc_cv_target_thread_file=posix"
    "cross_compiling=true"
    "--disable-multilib"

    "--enable-clocale=gnu"
    "--disable-libstdcxx-pch"
    "--disable-vtable-verify"
    "--enable-libstdcxx-visibility"
    "--with-default-libstdcxx-abi=new"
  ];

  preConfigure = ''
    cd "$buildRoot"
    configureScript=$sourceRoot/configure
    chmod +x "$configureScript"
  '';

  doCheck = true;

  postInstall = ''
    moveToOutput lib/libstdc++.modules.json "$dev"
  '';

  configurePlatforms = [
    "build"
    "host"
  ];

  enableParallelBuilding = true;

  hardeningDisable = [
    # PATH_MAX
    "fortify"
  ];

  postUnpack = ''
    mkdir -p ./build
    buildRoot=$(readlink -e "./build")
  '';

  preAutoreconf = ''
    sourceRoot=$(readlink -e "./libstdc++-v3")
    cd $sourceRoot
  '';

  passthru = {
    isGNU = true;
  };

  meta = gcc_meta // {
    description = "GNU C++ Library";
    homepage = "https://gcc.gnu.org/onlinedocs/libstdc++";
  };
})
