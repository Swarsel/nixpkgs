{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colcon,
  pytestCheckHook,
  scspell,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "colcon-parallel-executor";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-parallel-executor";
    tag = version;
    hash = "sha256-JjpVhBpkVNFOsTnY8vEqIre4Hzwg+eDYwrR2iaIC5TA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    scspell
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    colcon
  ];

  disabledTestPaths = [
    # Skip the linter tests
    "test/test_flake8.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "colcon_parallel_executor"
  ];

  meta = {
    description = "Extension for colcon-core to process packages in parallel";
    homepage = "https://github.com/colcon/colcon-parallel-executor";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
  };
}
