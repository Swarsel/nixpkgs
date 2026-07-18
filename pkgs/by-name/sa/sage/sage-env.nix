{
  lib,
  stdenv,
  bash,
  binutils,
  blas,
  cddlib,
  coreutils,
  eclib,
  ecm,
  env-locations,
  fflas-ffpack,
  flint,
  gap,
  gawk,
  gd,
  gfan,
  gfortran,
  giac,
  givaro,
  glpk,
  gmp,
  gnugrep,
  gnused,
  gsl,
  lapack,
  lcalc,
  less,
  libpng,
  linbox,
  m4ri,
  maxima,
  meson,
  mpfr,
  nauty,
  ninja,
  ntl,
  palp,
  pari,
  pkg-config,
  ppl,
  python3,
  pythonEnv,
  rWrapper,
  rubiks,
  sage-docbuild,
  sagelib,
  singular,
  sqlite,
  sympow,
  tachyon,
  writeTextFile,
  zlib,
}:

assert (!blas.isILP64) && (!lapack.isILP64);

# This generates a `sage-env` shell file that will be sourced by sage on startup.
# It sets up various environment variables, telling sage where to find its
# dependencies.

let
  runtimepath = (
    lib.makeBinPath [
      "@sage-local@"
      "@sage-local@/build"
      pythonEnv
      gfortran # for inline fortran
      ninja # for inline fortran via numpy.f2py
      meson # for inline fortran
      stdenv.cc # for cython
      bash
      coreutils
      gnused
      gnugrep
      gawk
      binutils.bintools
      pkg-config
      pari
      gap
      maxima.lisp-compiler
      maxima
      singular
      giac
      palp
      # needs to be rWrapper since the default `R` doesn't include R's default libraries
      rWrapper
      gfan
      cddlib
      tachyon
      glpk
      eclib
      sympow
      nauty
      sqlite
      ppl
      ecm
      lcalc
      rubiks
      less # needed to prevent transient test errors until https://github.com/ipython/ipython/pull/11864 is resolved
    ]
  );
in
writeTextFile rec {
  destination = "/${name}";
  name = "sage-env";

  text = ''
    export PKG_CONFIG_PATH='${
      lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
        # This should only be needed during build. However, since the  doctests
        # also test the cython build (for example in src/sage/misc/cython.py),
        # it is also needed for the testsuite to pass. We could fix the
        # testsuite instead, but since all the packages are also runtime
        # dependencies it doesn't really hurt to include them here.
        singular
        blas
        lapack
        fflas-ffpack
        givaro
        gd
        libpng
        zlib
        gsl
        linbox
        m4ri
      ]
    }'
    export PATH="${runtimepath}:$PATH"
    export SAGE_DOC="''${SAGE_DOC_OVERRIDE:-doc-placeholder}"
    export SAGE_DOC_SRC="''${SAGE_DOC_SRC_OVERRIDE:-${sagelib.src}/src/doc}"

    # set locations of dependencies
    . ${env-locations}/sage-env-locations

    # needed for cython
    export CC='${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc'
    export CXX='${stdenv.cc}/bin/${stdenv.cc.targetPrefix}c++'
    # cython needs to find these libraries, otherwise will fail with `ld: cannot find -lflint` or similar
    export LDFLAGS='${
      lib.concatStringsSep " " (
        map (pkg: "-L${pkg}/lib") [
          flint
          gap
          glpk
          gmp
          mpfr
          pari
          zlib
          eclib
          gsl
          ntl
          sympow
        ]
      )
    }'
    export CFLAGS='${
      lib.concatStringsSep " " (
        map (pkg: "-isystem ${pkg}/include") [
          singular
          gmp.dev
          glpk
          flint
          gap
          mpfr.dev
        ]
      )
    }'
    export CXXFLAGS=$CFLAGS

    export SAGE_LIB='${sagelib}/${python3.sitePackages}'

    export SAGE_EXTCODE='${sagelib.src}/src/sage/ext_data'

    # for find_library
    export DYLD_LIBRARY_PATH="${
      lib.makeLibraryPath [
        stdenv.cc.libc
        singular
        giac
        gap
      ]
    }''${DYLD_LIBRARY_PATH:+:}$DYLD_LIBRARY_PATH"
  '';

  passthru = {
    docbuild = sage-docbuild;
    lib = sagelib;
  };
}
