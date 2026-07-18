{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numba,
  numpy,
  pandas,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "numpy-groupies";
  version = "0.11.3";

  src = fetchFromGitHub {
    owner = "ml31415";
    repo = "numpy-groupies";
    tag = "v${version}";
    hash = "sha256-pg9hOtIgS8pB/Y9Xqto9Omsdg8TxaA5ZGE1Qh1DCceU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    numba
    pandas
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "numpy_groupies" ];

  meta = {
    description = "Optimised tools for group-indexing operations: aggregated sum and more";
    homepage = "https://github.com/ml31415/numpy-groupies";
    changelog = "https://github.com/ml31415/numpy-groupies/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ berquist ];
  };
}
