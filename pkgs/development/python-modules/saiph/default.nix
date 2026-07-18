{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  doubles,
  hatchling,
  msgspec,
  numpy,
  pandas,
  pydantic,
  pytestCheckHook,
  scikit-learn,
  scipy,
  toolz,
}:

buildPythonPackage rec {
  pname = "saiph";
  version = "2.0.8";

  src = fetchFromGitHub {
    owner = "octopize";
    repo = "saiph";
    tag = "saiph-v${version}";
    hash = "sha256-3KcCiGgcJ+1WLQPvxDJyGrn8TEiBVIh/9TsCMkku3ls=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    doubles
    msgspec
    numpy
    pandas
    pydantic
    scikit-learn
    scipy
    toolz
  ];

  # No need for benchmarks
  disabledTests = [
    "benchmark_test.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "saiph"
  ];

  pythonRelaxDeps = true;

  meta = {
    description = "Package enabling to project data";
    homepage = "https://github.com/octopize/saiph";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ b-rodrigues ];
  };
}
