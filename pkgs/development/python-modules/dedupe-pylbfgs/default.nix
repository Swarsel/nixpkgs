{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  numpy,
  # tests
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dedupe-pylbfgs";
  version = "0.2.0.16";

  # NOTE: This is a fork of larsmans/pylbfgs maintained by dedupeio
  src = fetchFromGitHub {
    owner = "dedupeio";
    repo = "pylbfgs";
    tag = version;
    hash = "sha256-H416dgZQxyqsnhmlK5keW8cJWY6gea4mebVuP0IEVOU=";
  };

  patches = [
    ./tests-numpy-2.4.patch # https://github.com/dedupeio/pylbfgs/pull/52
  ];

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  # Prevent importing from source during test collection (only $out has compiled extensions)
  preCheck = ''
    rm -rf lbfgs
  '';

  build-system = [
    cython
    numpy
    setuptools
  ];

  dependencies = [
    numpy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "lbfgs"
  ];

  meta = {
    description = "Python wrapper for L-BFGS and OWL-QN optimization algorithms";
    homepage = "https://github.com/dedupeio/pylbfgs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ daniel-fahey ];
  };
}
