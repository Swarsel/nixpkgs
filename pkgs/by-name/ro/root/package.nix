{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  apple-sdk,
  blas,
  callPackage,
  cmake,
  coreutils,
  curl,
  davix,
  fftw,
  freetype,
  ftgl,
  giflib,
  git,
  gl2ps,
  gnugrep,
  gnused,
  gsl,
  libGL,
  libGLU,
  libjpeg,
  libpng,
  libtiff,
  libx11,
  libxcrypt,
  libxext,
  libxft,
  libxml2,
  libxpm,
  llvm_20,
  lsof,
  lz4,
  makeWrapper,
  man,
  nlohmann_json,
  onetbb,
  openssl,
  patchRcPathCsh,
  patchRcPathFish,
  patchRcPathPosix,
  pcre2,
  pkg-config,
  procps,
  python3,
  which,
  writeText,
  xrootd,
  xxhash,
  xz,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "root";
  version = "6.40.00";

  src = fetchurl {
    url = "https://root.cern.ch/download/root_v${finalAttrs.version}.source.tar.gz";
    hash = "sha256-Z2+P3okmzgWQK+f0TOfUkqSiBgAi/KsOPRxE9twPveg=";
  };

  nativeBuildInputs = [
    makeWrapper
    cmake
    pkg-config
    git
  ];

  buildInputs = [
    finalAttrs.clang
    blas
    curl
    davix
    fftw
    ftgl
    giflib
    gl2ps
    gsl
    libjpeg
    libpng
    libtiff
    libxcrypt
    libxml2
    llvm_20
    lz4
    openssl
    patchRcPathCsh
    patchRcPathFish
    patchRcPathPosix
    pcre2
    python3
    onetbb
    xrootd
    xxhash
    xz
    zlib
    zstd
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk.privateFrameworksHook
    freetype
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libGLU
    libGL
    libx11
    libxpm
    libxft
    libxext
  ];

  propagatedBuildInputs = [
    nlohmann_json # link interface of target "ROOT::ROOTEve"
  ];

  cmakeFlags = [
    "-DCLAD_SOURCE_DIR=${finalAttrs.clad_src}"
    "-DClang_DIR=${finalAttrs.clang}/lib/cmake/clang"
    "-Dbuiltin_clang=OFF"
    "-Dbuiltin_llvm=OFF"
    "-Dfail-on-missing=ON"
    "-Dfftw3=ON"
    "-Dfitsio=OFF"
    "-Dmathmore=ON"
    "-Dsqlite=OFF"
    "-Dvdt=OFF"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # fatal error: module map file '/nix/store/<hash>-Libsystem-osx-10.12.6/include/module.modulemap' not found
    # fatal error: could not build module '_Builtin_intrinsics'
    "-Druntime_cxxmodules=OFF"
  ];

  preConfigure = ''
    for path in builtins/*; do
      if [[ "$path" != "builtins/openui5" ]] && [[ "$path" != "builtins/rendercore" ]]; then
        rm -rf "$path"
      fi
    done
    substituteInPlace cmake/modules/SearchInstalledSoftware.cmake \
      --replace-fail 'set(lcgpackages ' '#set(lcgpackages '

    patchShebangs cmake/unix/
  ''
  +
    lib.optionalString
      (stdenv.hostPlatform.isDarwin && lib.versionAtLeast stdenv.hostPlatform.darwinMinVersion "11")
      ''
        MACOSX_DEPLOYMENT_TARGET=10.16
      '';

  postInstall = ''
    for prog in rooteventselector rootmv rootprint rootslimtree; do
      wrapProgram "$out/bin/$prog" \
        --set PYTHONPATH "$out/lib"
    done

    # Make ldd and sed available to the ROOT executable by prefixing PATH.
    wrapProgram "$out/bin/root" \
      --prefix PATH : "${
        lib.makeBinPath [
          gnused # sed
          stdenv.cc # c++ ld etc.
          stdenv.cc.libc # ldd
        ]
      }"

    # Patch thisroot.{sh,csh,fish}

    # The main target of `thisroot.sh` is "bash-like shells",
    # but it also need to support Bash-less POSIX shell like dash,
    # as they are mentioned in `thisroot.sh`.

    patchRcPathPosix "$out/bin/thisroot.sh" "${
      lib.makeBinPath [
        coreutils # dirname tail
        gnugrep # grep
        gnused # sed
        lsof # lsof
        man # manpath
        procps # ps
        which # which
      ]
    }"
    patchRcPathCsh "$out/bin/thisroot.csh" "${
      lib.makeBinPath [
        coreutils
        gnugrep
        gnused
        lsof # lsof
        man
        which
      ]
    }"
    patchRcPathFish "$out/bin/thisroot.fish" "${
      lib.makeBinPath [
        coreutils
        man
        which
      ]
    }"
  '';

  clad_src = fetchFromGitHub {
    hash = "sha256-gEJlQ2Vg9EUX1tslI4HaUnusvdSomsYHiE8mZMygEOw=";
    owner = "vgvassilev";
    repo = "clad";
    # Make sure that this is the same tag as in the ROOT build files!
    # https://github.com/root-project/root/blob/master/interpreter/cling/tools/plugins/clad/CMakeLists.txt#L76
    tag = "v2.3";
  };

  # ROOT requires a patched version of clang
  clang = (callPackage ./clang-root.nix { });
  # To use the debug information on the fly (without installation)
  # add the outPath of root.debug into NIX_DEBUG_INFO_DIRS (in PATH-like format)
  # and make sure that gdb from Nixpkgs can be found in PATH.
  #
  # Darwin currently fails to support it (#203380)
  # we set it to true hoping to benefit from the future fix.
  # Before that, please make sure if root.debug exists before using it.
  separateDebugInfo = true;
  setupHook = ./setup-hook.sh;

  passthru = {
    tests = import ./tests { inherit callPackage; };
  };

  meta = {
    description = "Data analysis framework";
    homepage = "https://root.cern/";
    license = lib.licenses.lgpl21;

    maintainers = [
      lib.maintainers.guitargeek
      lib.maintainers.veprbl
    ];

    platforms = lib.platforms.unix;
  };
})
