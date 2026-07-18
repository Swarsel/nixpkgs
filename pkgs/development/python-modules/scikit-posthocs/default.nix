{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  matplotlib,
  numpy,
  pandas,
  pytestCheckHook,
  scipy,
  seaborn,
  seaborn-data,
  setuptools,
  statsmodels,
}:

buildPythonPackage rec {
  pname = "scikit-posthocs";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "maximtrp";
    repo = "scikit-posthocs";
    tag = "v${version}";
    hash = "sha256-hFqZVMsbFvqbfr0gHYsy0H6eCHJOxtz0vZm5Onk7Vzo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # tests require to write to home directory
    export SEABORN_DATA=${seaborn-data.exercise}
  '';

  build-system = [ setuptools ];

  dependencies = [
    matplotlib
    numpy
    pandas
    scipy
    seaborn
    statsmodels
  ];

  pyproject = true;
  pythonImportsCheck = [ "scikit_posthocs" ];

  meta = {
    description = "Multiple Pairwise Comparisons (Post Hoc) Tests in Python";
    homepage = "https://github.com/maximtrp/scikit-posthocs";
    changelog = "https://github.com/maximtrp/scikit-posthocs/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
