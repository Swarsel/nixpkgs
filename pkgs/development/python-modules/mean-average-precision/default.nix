{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pandas,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mean-average-precision";
  version = "2024.01.05.0";

  src = fetchFromGitHub {
    owner = "bes-dev";
    repo = "mean_average_precision";
    tag = version;
    hash = "sha256-qo160L+oJsHERVOV0qdiRIZPMjvSlUmMTrAzThfrQSs=";
  };

  # No tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    pandas
  ];

  pyproject = true;

  pythonImportsCheck = [
    "mean_average_precision"
  ];

  meta = {
    description = "Mean Average Precision for Object Detection";
    homepage = "https://github.com/bes-dev/mean_average_precision";
    changelog = "https://github.com/bes-dev/mean_average_precision/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
