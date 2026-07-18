{
  lib,
  stdenv,
  fetchurl,
  arpack,
  blas,
  callPackage,
  config,
  curl,
  fast-float,
  # Both are needed for discrete Fourier transform
  fftw,
  fftwSinglePrec,
  flex,
  fltk,
  gfortran,
  ghostscript,
  gl2ps,
  glpk,
  gnuplot,
  graphicsmagick,
  hdf5,
  jdk,
  lapack,
  libGL,
  libGLU,
  libiconv,
  libsForQt5,
  libsndfile,
  libwebp,
  libx11,
  makeSetupHook,
  makeWrapper,
  ncurses,
  # - Packages required for building extra packages.
  newScope,
  pcre2,
  perl,
  pkg-config,
  pkgs,
  portaudio,
  python3,
  qhull,
  # These 3 should use the same lapack and blas as the above, see code prepending
  qrupdate,
  rapidjson,
  readline,
  suitesparse,
  sundials,
  testers,
  texinfo,
  zlib,
  # - Build Java interface:
  enableJava ? true,
  # - Build Octave Qt GUI:
  enableQt ? false,
  # - Include support for GNU readline:
  enableReadline ? true,
  # If set to true, the above 5 deps are overridden to use the blas and lapack
  # with 64 bit indexes support. If all are not compatible, the build will fail.
  use64BitIdx ? false,
}:

let
  # Not always evaluated
  blas' =
    if use64BitIdx then
      blas.override {
        isILP64 = true;
      }
    else
      blas;
  lapack' =
    if use64BitIdx then
      lapack.override {
        isILP64 = true;
      }
    else
      lapack;
  qrupdate' = qrupdate.override {
    # If use64BitIdx is false, this override doesn't evaluate to a new
    # derivation, as blas and lapack are not overridden.
    blas = blas';
    lapack = lapack';
  };
  arpack' = arpack.override {
    blas = blas';
    lapack = lapack';
  };
  # We keep the option to not enable suitesparse support by putting it null
  suitesparse' =
    if suitesparse != null then
      suitesparse.override {
        blas = blas';
        lapack = lapack';
      }
    else
      null;
  # To avoid confusion later in passthru
  allPkgs = pkgs;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "octave";
  version = "11.3.0";

  src = fetchurl {
    url = "mirror://gnu/octave/octave-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-y1if6zzvhNE0hUaDcYycE+C0ceqRbQdhvnqMTiYaMtE=";
  };

  postPatch = ''
    patchShebangs --build build-aux/*.pl
  '';

  nativeBuildInputs = [
    perl
    pkg-config
    gfortran
    texinfo
  ]
  ++ lib.optionals enableQt [
    libsForQt5.wrapQtAppsHook
    libsForQt5.qtscript
    libsForQt5.qttools
  ];

  buildInputs = [
    readline
    ncurses
    flex
    qhull
    graphicsmagick
    pcre2
    fltk
    zlib
    curl
    rapidjson
    blas'
    lapack'
    libsndfile
    fftw
    fftwSinglePrec
    portaudio
    qrupdate'
    arpack'
    libwebp
    gl2ps
    ghostscript
    hdf5
    glpk
    suitesparse'
    sundials
    gnuplot
    python3
  ]
  ++ lib.optionals enableQt [
    libsForQt5.qtbase
    libsForQt5.qtsvg
    libsForQt5.qscintilla
  ]
  ++ lib.optionals enableJava [
    jdk
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libGL
    libGLU
    libx11
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    fast-float
  ];

  configureFlags = [
    "--with-blas=blas"
    "--with-lapack=lapack"
    (if use64BitIdx then "--enable-64" else "--disable-64")
  ]
  ++ lib.optionals enableReadline [ "--enable-readline" ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ "--with-x=no" ]
  ++ lib.optionals enableQt [ "--with-qt=5" ];

  env =
    lib.optionalAttrs stdenv.hostPlatform.isDarwin {
      # https://savannah.gnu.org/bugs/index.php?68042
      NIX_CFLAGS_COMPILE = "-Wno-format-security";
      # Fix linker error on Darwin (see https://trac.macports.org/ticket/61865)
      NIX_LDFLAGS = "-lobjc";
    }
    // lib.optionalAttrs use64BitIdx {
      # See https://savannah.gnu.org/bugs/?50339
      F77_INTEGER_8_FLAG = "-fdefault-integer-8";
    };

  doCheck = !stdenv.hostPlatform.isDarwin;

  # Keep a copy of the octave tests detailed results in the output
  # derivation, because someone may care
  postInstall = ''
    cp test/fntests.log $out/share/octave/octave-${finalAttrs.version}-fntests.log || true
  '';

  enableParallelBuilding = true;

  passthru = rec {
    inherit fftw fftwSinglePrec;
    inherit portaudio;
    inherit jdk;
    inherit enableQt enableReadline enableJava;
    arpack = arpack';
    blas = blas';

    buildEnv = callPackage ./build-env.nix {
      inherit wrapOctave;
      inherit (octavePackages) computeRequiredOctavePackages;
      octave = finalAttrs.finalPackage;
    };

    interpreter = "${finalAttrs.finalPackage}/bin/octave";
    lapack = lapack';
    octPkgsPath = "share/octave/octave_packages";

    octavePackages = import ../../../top-level/octave-packages.nix {
      inherit
        config
        lib
        stdenv
        fetchurl
        newScope
        ;

      octave = finalAttrs.finalPackage;
      pkgs = allPkgs;
    };

    pkgs = octavePackages;
    python = python3;
    qrupdate = qrupdate';
    sitePath = "share/octave/${finalAttrs.version}/site";
    suitesparse = suitesparse';

    tests = {
      wrapper = testers.testVersion {
        command = "octave --version";
        package = finalAttrs.finalPackage.withPackages (ps: [ ps.doctest ]);
      };
    };

    withPackages = import ./with-packages.nix { inherit buildEnv octavePackages; };

    wrapOctave = callPackage ./wrap-octave.nix {
      inherit (allPkgs) makeSetupHook makeWrapper;
      octave = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Scientific Programming Language";
    homepage = "https://www.gnu.org/software/octave/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      raskin
      doronbehar
    ];
  };
})
