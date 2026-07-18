{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  matplotlib,
  networkx,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "scikit-fuzzy";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "scikit-fuzzy";
    repo = "scikit-fuzzy";
    tag = "v${version}";
    hash = "sha256-02aIYBdbQXQD9S1R/gZZeKTn5LxloE0GGGRttxJnR/o=";
  };

  nativeCheckInputs = [
    matplotlib
    pytestCheckHook
  ];

  preCheck = "rm -rf build";
  build-system = [ setuptools ];

  dependencies = [
    networkx
    numpy
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "skfuzzy" ];

  meta = {
    description = "Fuzzy logic toolkit for scientific Python";
    homepage = "https://github.com/scikit-fuzzy/scikit-fuzzy";
    changelog = "https://github.com/scikit-fuzzy/scikit-fuzzy/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.bcdarwin ];
  };
}
