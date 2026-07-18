{
  lib,
  stdenv,
  fetchurl,
  boost,
  lhapdf,
  ncurses,
  perl,
  swig,
  yoda,
  zlib,
  python ? null,
  withPython ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fastnlo-toolkit";
  version = "2.5.0-2826";

  src = fetchurl {
    url = "https://fastnlo.hepforge.org/code/v25/fastnlo_toolkit-${finalAttrs.version}.tar.gz";
    hash = "sha256-7aIMYCOkHC/17CHYiEfrxvtSJxTDivrS7BQ32cGiEy0=";
  };

  patches = [
    # Compatibility with YODA 2.x
    ./yoda2_support.patch
  ];

  postPatch = ''
    substituteInPlace py-compile \
      --replace-fail "import sys, os, py_compile, imp" "import sys, os, py_compile, importlib" \
      --replace-fail "imp." "importlib." \
      --replace-fail "hasattr(imp" "hasattr(importlib"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    lhapdf # lhapdf-config
    yoda # yoda-config
  ]
  ++ lib.optional withPython python;

  buildInputs = [
    boost
    lhapdf
    yoda
  ]
  ++ lib.optional withPython python
  ++ lib.optional (withPython && python.isPy3k) ncurses;

  propagatedBuildInputs = [
    zlib
  ]
  ++ lib.optional withPython python.pkgs.distutils;

  configureFlags = [
    "--with-yoda=${yoda}"
  ]
  ++ lib.optional withPython "--enable-pyext";

  # None of our currently packaged versions of swig are C++17-friendly
  # Use a workaround from https://github.com/swig/swig/issues/1538
  env.CXXFLAGS = "-D_LIBCPP_ENABLE_CXX17_REMOVED_FEATURES";

  preConfigure = ''
    substituteInPlace ./fastnlotoolkit/Makefile.in \
      --replace "-fext-numeric-literals" ""

    # disable test that fails due to strict floating-point number comparison
    echo "#!/usr/bin/env perl" > check/fnlo-tk-stattest.pl.in
    chmod +x check/fnlo-tk-stattest.pl.in
  '';

  doCheck = true;

  nativeCheckInputs = [
    perl
    lhapdf.pdf_sets.CT10nlo
  ];

  preCheck = ''
    patchShebangs --build check
  '';

  enableParallelBuilding = true;
  enableParallelChecking = false;
  propagatedNativeBuildInputs = lib.optional withPython swig;

  meta = {
    description = "Fast pQCD calculations for hadron-induced processes";

    longDescription = ''
      The fastNLO project provides computer code to create and evaluate fast
      interpolation tables of pre-computed coefficients in perturbation theory
      for observables in hadron-induced processes.

      This allows fast theory predictions of these observables for arbitrary
      parton distribution functions (of regular shape), renormalization or
      factorization scale choices, and/or values of alpha_s(Mz) as e.g. needed
      in PDF fits or in systematic studies. Very time consuming complete
      recalculations are thus avoided.
    '';

    homepage = "http://fastnlo.hepforge.org";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ veprbl ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
