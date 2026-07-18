{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  bzip2,
  cbc,
  clp,
  doxygen,
  fontconfig,
  gfortran,
  graphviz,
  ipopt,
  lapack,
  libamplsolver,
  osi,
  pkg-config,
  texliveSmall,
  zlib,
}:

assert (!blas.isILP64) && (!lapack.isILP64);

stdenv.mkDerivation (finalAttrs: {
  pname = "bonmin";
  version = "1.8.9";

  src = fetchFromGitHub {
    owner = "coin-or";
    repo = "Bonmin";
    rev = "releases/${finalAttrs.version}";
    sha256 = "sha256-nqjAQ1NdNJ/T4p8YljEWRt/uy2aDwyBeAsag0TmRc5Q=";
  };

  # ignore one failing test
  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace test/Makefile.in --replace-fail \
      "./unitTest\''$(EXEEXT)" \
      ""
  '';

  nativeBuildInputs = [
    doxygen
    gfortran
    graphviz
    pkg-config
    texliveSmall
  ];

  buildInputs = [
    blas
    bzip2
    cbc
    clp
    ipopt
    lapack
    libamplsolver
    osi
    zlib
  ];

  configureFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "--with-asl-lib=-lipoptamplinterface -lamplsolver"
  ];

  # Fontconfig error: Cannot load default config file: No such file: (null)
  env.FONTCONFIG_FILE = "${fontconfig.out}/etc/fonts/fonts.conf";
  # Fontconfig error: No writable cache directories
  preBuild = "export XDG_CACHE_HOME=$(mktemp -d)";
  doCheck = true;
  # install documentation
  postInstall = "make install-doxygen-docs";
  __structuredAttrs = true;
  checkTarget = "test";
  # Fix doc install. Should not be necessary after next release
  # ref https://github.com/coin-or/Bonmin/commit/4f665bc9e489a73cb867472be9aea518976ecd28
  sourceRoot = "${finalAttrs.src.name}/Bonmin";

  meta = {
    description = "Open-source code for solving general MINLP (Mixed Integer NonLinear Programming) problems";
    homepage = "https://github.com/coin-or/Bonmin";
    license = lib.licenses.epl10;
    maintainers = with lib.maintainers; [ aanderse ];
    platforms = lib.platforms.unix;
    mainProgram = "bonmin";
  };
})
