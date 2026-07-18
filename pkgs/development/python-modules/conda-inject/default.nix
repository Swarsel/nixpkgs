{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  poetry-core,
  # dependencies
  pyyaml,
}:

buildPythonPackage rec {
  pname = "conda-inject";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "koesterlab";
    repo = "conda-inject";
    tag = "v${version}";
    hash = "sha256-M4+bz7ZuHlcF8tF5kSCUjjkIHG75eCCW1IJxcwxNL6o=";
  };

  # no tests
  doCheck = false;

  build-system = [
    poetry-core
  ];

  dependencies = [
    pyyaml
  ];

  pyproject = true;

  pythonImportsCheck = [
    "conda_inject"
  ];

  meta = {
    description = "Helper functions for injecting a conda environment into the current python environment";
    homepage = "https://github.com/koesterlab/conda-inject";
    changelog = "https://github.com/koesterlab/conda-inject/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
