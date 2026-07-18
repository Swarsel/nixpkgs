{
  lib,
  stdenv,
  blas,
  boost,
  brial,
  buildPythonPackage,
  cliquer,
  conway-polynomials,
  cvxopt,
  cypari2,
  cysignals,
  cython,
  eclib,
  ecm,
  env-locations,
  fflas-ffpack,
  flint,
  fpylll,
  gap,
  gd,
  givaro,
  glpk,
  gmpy2,
  gsl,
  iml,
  importlib-metadata,
  importlib-resources,
  ipykernel,
  ipython,
  ipywidgets,
  jupyter-client,
  jupyter-core,
  lapack,
  lcalc,
  libbraiding,
  libhomfly,
  libmpc,
  libpng,
  linbox,
  lisp-compiler,
  lrcalc,
  lrcalc-python,
  m4,
  m4ri,
  m4rie,
  matplotlib,
  memory-allocator,
  meson-python,
  mpfi,
  mpfr,
  mpmath,
  networkx,
  ntl,
  numpy,
  pari,
  perl,
  pexpect,
  pillow,
  pip,
  pkg-config,
  pkgconfig,
  planarity,
  ppl,
  pplpy,
  primecountpy,
  ptyprocess,
  pytest,
  python,
  rankwidth,
  requests,
  rpy2,
  sage-docbuild,
  sage-setup,
  sage-src,
  scipy,
  setuptools,
  singular,
  sphinx,
  sqlite,
  symmetrica,
  sympy,
  typing-extensions,
}:

assert (!blas.isILP64) && (!lapack.isILP64);

# This is the core sage python package. Everything else is just wrappers gluing
# stuff together. It is not very useful on its own though, since it will not
# find many of its dependencies without `sage-env`, will not be tested without
# `sage-tests` and will not have html docs without `sagedoc`.

buildPythonPackage rec {
  pname = "sagelib";
  version = src.version;
  src = sage-src;

  nativeBuildInputs = [
    iml
    lisp-compiler
    m4
    perl
    pip # needed to query installed packages
    pkg-config
    sage-setup
    setuptools
    meson-python
    cython
  ];

  buildInputs = [
    gd
    iml
    libpng
  ];

  propagatedBuildInputs = [
    # native dependencies (TODO: determine which ones need to be propagated)
    blas
    boost
    brial
    cliquer
    eclib
    ecm
    fflas-ffpack
    flint
    gap
    givaro
    glpk
    gsl
    lapack
    lcalc
    libbraiding
    libhomfly
    libmpc
    linbox
    lisp-compiler
    lrcalc
    m4ri
    m4rie
    mpfi
    mpfr
    ntl
    pari
    planarity
    ppl
    rankwidth
    singular
    sqlite
    symmetrica

    # from src/sage/setup.cfg and requirements.txt
    conway-polynomials
    cvxopt
    cypari2
    cysignals
    cython
    fpylll
    gmpy2
    importlib-metadata
    importlib-resources
    ipykernel
    ipython
    ipywidgets
    jupyter-client
    jupyter-core
    lrcalc-python
    matplotlib
    memory-allocator
    mpmath
    networkx
    numpy
    pexpect
    pillow
    pip
    pkgconfig
    pplpy
    primecountpy
    ptyprocess
    pytest
    requests
    rpy2
    sage-docbuild
    scipy
    sphinx
    sympy
    typing-extensions
  ];

  mesonFlags = [ "-Dbuild-docs=false" ];

  env = lib.optionalAttrs stdenv.cc.isClang {
    # code tries to assign a unsigned long to an int in an initialized list
    # leading to this error.
    # https://github.com/sagemath/sage/pull/39249
    NIX_CFLAGS_COMPILE = "-Wno-error=c++11-narrowing-const-reference";
  };

  preBuild = ''
    patchShebangs src/sage_setup/autogen/interpreters/__main__.py
  '';

  doCheck = false; # we will run tests in sage-tests.nix
  pyproject = true;
}
