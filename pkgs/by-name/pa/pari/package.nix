{
  lib,
  stdenv,
  fetchurl,
  gmp,
  libpthread-stubs,
  libx11,
  perl,
  readline,
  texliveBasic,
  withThread ? true,
}:

assert withThread -> libpthread-stubs != null;

stdenv.mkDerivation rec {
  pname = "pari";
  version = "2.17.3";

  src = fetchurl {
    hash = "sha256-jZxPzVhMRo0n4PI8NoNlhyhEUglMSxxATCDEuBBGLcs=";

    urls = [
      "https://pari.math.u-bordeaux.fr/pub/pari/unix/${pname}-${version}.tar.gz"
      # old versions are at the url below
      "https://pari.math.u-bordeaux.fr/pub/pari/OLD/${lib.versions.majorMinor version}/${pname}-${version}.tar.gz"
    ];
  };

  buildInputs = [
    gmp
    libx11
    perl
    readline
    texliveBasic
  ]
  ++ lib.optionals withThread [
    libpthread-stubs
  ];

  configureFlags = [
    "--with-gmp=${lib.getDev gmp}"
    "--with-readline=${lib.getDev readline}"
  ]
  ++ lib.optional withThread "--mt=pthread";

  makeFlags = [ "all" ];

  preConfigure = ''
    export LD=$CC
  '';

  configureScript = "./Configure";

  meta = {
    description = "Computer algebra system for high-performance number theory computations";

    longDescription = ''
      PARI/GP is a widely used computer algebra system designed for fast
      computations in number theory (factorizations, algebraic number theory,
      elliptic curves...), but also contains a large number of other useful
      functions to compute with mathematical entities such as matrices,
      polynomials, power series, algebraic numbers etc., and a lot of
      transcendental functions. PARI is also available as a C library to allow
      for faster computations.

      Originally developed by Henri Cohen and his co-workers (Université
      Bordeaux I, France), PARI is now under the GPL and maintained by Karim
      Belabas with the help of many volunteer contributors.

      - PARI is a C library, allowing fast computations.
      - gp is an easy-to-use interactive shell giving access to the PARI
        functions.
      - GP is the name of gp's scripting language.
      - gp2c, the GP-to-C compiler, combines the best of both worlds by
        compiling GP scripts to the C language and transparently loading the
        resulting functions into gp. (gp2c-compiled scripts will typically run
        3 or 4 times faster.) gp2c currently only understands a subset of the
        GP language.
    '';

    homepage = "http://pari.math.u-bordeaux.fr";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "gp";
    downloadPage = "http://pari.math.u-bordeaux.fr/download.html";
    teams = [ lib.teams.sage ];
  };
}
