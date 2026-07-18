{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  buildPackages,
  curl,
  doxygen,
  gettext,
  # Upstream's `plot` UX is not ideal - it doesn't write a good message
  # suggesting the user to install this optional dependency when they write
  # `plot(..)`. Not to mention support for non-x dependent `gnuplot_qt`
  # executable. Hence we hardcode a path to a gnuplot binary by default, and
  # changing this is possible via putting an empty string as a `gnuplotBinary`
  # - to let `libqalculate` pick it from $PATH during runtime. See also:
  # https://github.com/Qalculate/libqalculate/issues/796
  gnuplot,
  icu,
  libiconv,
  libxml2,
  mpfr,
  pkg-config,
  readline,
  gnuplotBinary ? lib.getExe gnuplot,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libqalculate";
  version = "5.12.0";

  src = fetchFromGitHub {
    owner = "qalculate";
    repo = "libqalculate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f9FzFcu2LtBM6B6apYo7uobeR5uZVb02FxX7Kng/rRI=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
  ];

  postPatch = lib.optionalString (gnuplotBinary != "") ''
    substituteInPlace libqalculate/Calculator-plot.cc \
      --replace-fail 'commandline = "gnuplot"' 'commandline = "${gnuplotBinary}"' \
      --replace-fail '"gnuplot - ' '"${gnuplotBinary} - '
  '';

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    doxygen
  ];

  buildInputs = [
    curl
    gettext
    libiconv
    readline
  ];

  propagatedBuildInputs = [
    libxml2
    mpfr
    icu
  ];

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Advanced calculator library";
    homepage = "http://qalculate.github.io";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      doronbehar
      pentane
    ];

    platforms = lib.platforms.all;
    mainProgram = "qalc";
  };
})
