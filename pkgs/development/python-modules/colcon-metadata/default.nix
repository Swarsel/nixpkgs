{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colcon,
  pytest-cov-stub,
  pytestCheckHook,
  pyyaml,
  scspell,
  setuptools,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage rec {
  pname = "colcon-metadata";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-metadata";
    tag = version;
    hash = "sha256-CCyhtTsSjaeY/OKO8F1zYpk8yA4HlUoXVTVkyYEpVU8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    scspell
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    colcon
    pyyaml
  ];

  disabledTestPaths = [
    "test/test_flake8.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "colcon_metadata"
  ];

  meta = {
    description = "Extension for colcon-core to read package metadata from files";
    homepage = "http://colcon.readthedocs.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
    downloadPage = "https://github.com/colcon/colcon-metadata";
  };
}
