{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  blas,
  boehmgc,
  gettext,
  gmp,
  lapack,
  libtool,
  mpfr,
  ntl,
  windows,
  openblas ? null,
  withBlas ? true,
  withGc ? false,
  withNtl ? !ntl.meta.broken,
}:

assert
  withBlas
  -> openblas != null && blas.implementation == "openblas" && lapack.implementation == "openblas";

stdenv.mkDerivation (finalAttrs: {
  pname = "flint";
  version = "3.6.0";

  src = fetchurl {
    url = "https://flintlib.org/download/flint-${finalAttrs.version}.tar.gz";
    hash = "sha256-uV4sd5L17qShyNLULECYQ0dWgy5XoJSyletd/cm0w2s=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    gettext
    libtool
  ];

  buildInputs = [
    gmp
  ]
  ++ lib.optionals withBlas [
    openblas
  ]
  ++ lib.optionals withNtl [
    ntl
  ]
  ++ lib.optionals withGc [
    boehmgc
  ]
  ++ lib.optionals stdenv.hostPlatform.isMinGW [
    windows.pthreads
  ];

  propagatedBuildInputs = [
    mpfr
  ];

  configureFlags = [
    "--with-gmp=${gmp}"
    "--with-mpfr=${mpfr}"
  ]
  ++ lib.optionals withBlas [
    "--with-blas=${openblas}"
  ]
  ++ lib.optionals withNtl [
    "--with-ntl=${ntl}"
  ]
  ++ lib.optionals withGc [
    "--with-gc=${boehmgc}"
  ];

  # We're not using autoreconfHook because flint's bootstrap
  # script calls autoreconf, among other things.
  preConfigure = ''
    echo "Executing bootstrap.sh"
    ./bootstrap.sh
  '';

  doCheck = true;
  enableParallelBuilding = true;
  enableParallelChecking = true;

  meta = {
    description = "Fast Library for Number Theory";
    homepage = "https://www.flintlib.org/";
    license = lib.licenses.lgpl3Plus;

    maintainers = [
      lib.maintainers.smasher164
      lib.maintainers.wegank
    ];

    platforms = lib.platforms.all;

    # > checking for library containing cblas_dgemm... no
    broken =
      withBlas
      && stdenv.hostPlatform.isStatic
      && stdenv.hostPlatform.isLinux
      && stdenv.hostPlatform.isAarch64;

    downloadPage = "https://www.flintlib.org/downloads.html";
    teams = [ lib.teams.sage ];
  };
})
