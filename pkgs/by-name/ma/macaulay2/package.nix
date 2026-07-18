{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  R,
  _4ti2,
  autoreconfHook,
  bison,
  blas,
  boehmgc,
  boost,
  cddlib,
  cohomcalg,
  csdp,
  eigen,
  emacs-nox,
  fflas-ffpack,
  flex,
  flint,
  frobby,
  gdbm,
  getconf,
  gfan,
  gfortran,
  givaro,
  glpk,
  gtest,
  icu,
  jansson,
  libffi,
  libxml2,
  libz,
  llvmPackages,
  lrs,
  makeWrapper,
  mathic,
  mathicgb,
  memtailor,
  mpfi,
  mpfr,
  mpsolve,
  msolve,
  nauty,
  normaliz,
  ntl,
  onetbb,
  openssl,
  pkg-config,
  python3,
  rWrapper,
  readline,
  runCommand,
  runtimeShell,
  singular,
  texinfo,
  topcom,
  which,
  writableTmpDirAsHomeHook,
  xz,
  downloadDocs ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "macaulay2";
  version = "1.26.06";

  src = fetchFromGitHub {
    owner = "Macaulay2";
    repo = "M2";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-2e39qzBO63Ft+yw+tJChLsupeinalTkDwXp3WBF2wms=";
    fetchSubmodules = true;
  };

  postPatch = ''
    sed -i 's/AC_SUBST(REL,.*uname -r.*)/AC_SUBST(REL,"")/' configure.ac
    substituteInPlace configure.ac \
      --replace-fail "[\$gfan_version], [ge], [0.8]" "[\$gfan_version], [ge], [0.6]"
    substituteInPlace Macaulay2/packages/gfanInterface.m2 \
      --replace-fail 'MinimumVersion => ("0.8"' 'MinimumVersion => ("0.6"'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    bison
    emacs-nox
    flex
    gdbm
    getconf
    gfortran
    makeWrapper
    pkg-config
    texinfo
    which

    # TODO the configure script looks for these in $PATH
    _4ti2
    cohomcalg
    csdp
    gfan
    lrs
    msolve
    nauty
    normaliz
    topcom
  ];

  buildInputs = [
    blas
    boehmgc
    boost
    cddlib
    eigen
    fflas-ffpack
    flint
    frobby
    gdbm
    getconf
    givaro
    glpk
    gtest
    icu
    jansson
    libffi
    libxml2
    libz
    mathic
    mathicgb
    memtailor
    mpfi
    mpfr
    mpsolve
    msolve
    nauty
    ntl
    normaliz
    onetbb
    openssl
    python3
    readline
    singular
    xz
  ]
  ++ lib.optionals stdenv.cc.isClang [
    llvmPackages.openmp
  ];

  configureFlags = [
    "--disable-download"
    "--enable-shared"
    "--with-issue=Nix"
    "--with-boost-libdir=${boost}/lib"
    "--with-system-libs"
    "CPPFLAGS=-I${lib.getDev cddlib}/include/cddlib"
    "PYTHON_BIN=${python3.interpreter}"
  ];

  buildFlags = lib.optionals downloadDocs [
    "MakeDocumentation=false"
  ];

  env.LDFLAGS = lib.concatStringsSep " " (
    lib.optionals stdenv.hostPlatform.isDarwin [
      "-lblas"
    ]
  );

  preConfigure = ''
    cd BUILD/build
  '';

  preBuild = lib.optionalString downloadDocs ''
    ln -s ${finalAttrs.docs} ../tarfiles/${finalAttrs.docs.name}
    make -C libraries all-in-Macaulay2-docs
  '';

  postInstall = ''
    substituteInPlace "$out/bin/M2" \
      --replace-fail "/bin/sh" "${runtimeShell}"

    wrapProgram "$out/bin/M2-binary" \
      --prefix PATH : ${
        lib.makeBinPath [
          _4ti2
          cohomcalg
          csdp
          gfan
          lrs
          msolve
          nauty
          normaliz
          openssl
          R
          topcom
        ]
      } \
      --prefix ${if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH"} : ${
        lib.makeLibraryPath [
          cddlib
          flint
          givaro
          glpk
          mpfi
          mpfr
          mpsolve
          normaliz
          ntl
          singular
        ]
      } \
      --prefix R_LIBS_SITE : ${lib.makeSearchPath "library" rWrapper.recommendedPackages}
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/M2 --check 1
    runHook postInstallCheck
  '';

  __structuredAttrs = true;

  configurePlatforms = [
    "build"
    "host"
  ];

  configureScript = "../../configure";

  docs = fetchurl {
    hash = "sha256-0+ilvDh87Gmwzx0bLhT6nnadcPwgU3uB6pKhP9VqW0Q=";
    url = "https://macaulay2.com/Downloads/OtherSourceCode/Macaulay2-docs-${finalAttrs.version}.tar.gz";
  };

  enableParallelBuilding = true;
  sourceRoot = "${finalAttrs.src.name}/M2";

  passthru.tests = {
    all-packages =
      runCommand "macaulay2-all-packages-test"
        {
          nativeBuildInputs = [
            finalAttrs.finalPackage
            writableTmpDirAsHomeHook
          ];
        }
        ''
          M2 --check 3 && touch $out
        '';

    core =
      runCommand "macaulay2-core-tests"
        {
          nativeBuildInputs = [
            finalAttrs.finalPackage
            writableTmpDirAsHomeHook
          ];
        }
        ''
          M2 --check 2 && touch $out
        '';
  };

  meta = {
    description = "System for computing in commutative algebra, algebraic geometry and related fields";

    longDescription = ''
      Macaulay2 is a software system devoted to supporting research in
      algebraic geometry and commutative algebra, whose creation has been
      funded by the National Science Foundation since 1992.

      Macaulay2 includes core algorithms for computing Gröbner bases and graded
      or multi-graded free resolutions of modules over quotient rings of graded
      or multi-graded polynomial rings with a monomial ordering. The core
      algorithms are accessible through a versatile high level interpreted user
      language with a powerful debugger supporting the creation of new classes
      of mathematical objects and the installation of methods for computing
      specifically with them. Macaulay2 can compute Betti numbers, Ext,
      cohomology of coherent sheaves on projective varieties, primary
      decomposition of ideals, integral closure of rings, and more.
    '';

    homepage = "https://macaulay2.com/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ coolcuber ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "M2";
  };
})
