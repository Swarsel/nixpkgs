{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cysignals,
  cython,
  fplll,
  gmp,
  mpfr,
  numpy,
  pari,
  pkgconfig,
  # tests
  pytestCheckHook,
  # Reverse dependency
  sage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fpylll";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "fplll";
    repo = "fpylll";
    tag = version;
    hash = "sha256-vks4rTXk6fh8183PCxJzfTXQyo3scBH4afjbQAkT6Gw=";
  };

  nativeBuildInputs = [
    cython
    cysignals
    pkgconfig
    setuptools
  ];

  buildInputs = [
    gmp
    pari
    mpfr
    fplll
  ];

  propagatedBuildInputs = [
    numpy
    cysignals
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # Since upstream introduced --doctest-modules in
    # https://github.com/fplll/fpylll/commit/9732fdb40cf1bd43ad1f60762ec0a8401743fc79,
    # it is necessary to ignore import mismatches. Not sure why, but the files
    # should be identical anyway.
    export PY_IGNORE_IMPORTMISMATCH=1
  '';

  pyproject = true;

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "Python interface for fplll";
    homepage = "https://github.com/fplll/fpylll";
    changelog = "https://github.com/fplll/fpylll/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Plus;
    teams = [ lib.teams.sage ];
  };
}
