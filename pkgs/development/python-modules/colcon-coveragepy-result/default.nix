{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colcon,
  coverage,
  pytest-cov-stub,
  pytestCheckHook,
  scspell,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "colcon-coveragepy-result";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-coveragepy-result";
    tag = finalAttrs.version;
    hash = "sha256-+xjrmiWaDPjoRwjgP4Ui6+vuG4Nc4ur8DdC8ddiXAG0=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    scspell
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    colcon
    coverage
  ];

  disabledTestPaths = [
    "test/test_flake8.py" # flake tests doesn't work currently
  ];

  pyproject = true;

  pythonImportsCheck = [
    "colcon_coveragepy_result"
  ];

  meta = {
    description = "Colcon extension for collecting coverage.py results";
    homepage = "https://colcon.readthedocs.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
    downloadPage = "https://github.com/colcon/colcon-coveragepy-result.git";
  };
})
