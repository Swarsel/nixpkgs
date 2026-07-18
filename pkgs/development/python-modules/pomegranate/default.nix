{
  lib,
  stdenv,
  fetchFromGitHub,
  apricot-select,
  buildPythonPackage,
  fetchpatch,
  networkx,
  numpy,
  pytestCheckHook,
  scikit-learn,
  scipy,
  setuptools,
  torch,
}:

buildPythonPackage rec {
  pname = "pomegranate";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "jmschrei";
    repo = "pomegranate";
    tag = "v${version}";
    hash = "sha256-p2Gn0FXnsAHvRUeAqx4M1KH0+XvDl3fmUZZ7MiMvPSs=";
  };

  patches = [
    # Fix tests for pytorch 2.6
    (fetchpatch {
      hash = "sha256-BXsVhkuL27QqK/n6Fa9oJCzrzNcL3EF6FblBeKXXSts=";
      name = "python-2.6.patch";
      url = "https://github.com/jmschrei/pomegranate/pull/1142/commits/9ff5d5e2c959b44e569937e777b26184d1752a7b.patch";
    })
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    apricot-select
    networkx
    numpy
    scikit-learn
    scipy
    torch
  ];

  disabledTestPaths = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) [
    # AssertionError: Arrays are not almost equal to 6 decimals
    "tests/distributions/test_normal_full.py::test_fit"
    "tests/distributions/test_normal_full.py::test_from_summaries"
    "tests/distributions/test_normal_full.py::test_serialization"
  ];

  disabledTests = [
    # AssertionError: Arrays are not almost equal to 6 decimals
    "test_sample"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pomegranate" ];

  meta = {
    description = "Probabilistic and graphical models for Python, implemented in cython for speed";
    homepage = "https://github.com/jmschrei/pomegranate";
    changelog = "https://github.com/jmschrei/pomegranate/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rybern ];
  };
}
