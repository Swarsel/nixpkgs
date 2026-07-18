{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  colcon,
  # tests
  pytestCheckHook,
  scspell,
  # build-system
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "colcon-recursive-crawl";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-recursive-crawl";
    tag = version;
    hash = "sha256-zmmEelMjsIbXy5LchZMtr2+x+Ne2c2PhexLjbkZJmm8=";
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
    # Skip the linter tests that require additional dependencies
    "test/test_flake8.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "colcon_recursive_crawl" ];

  meta = {
    description = "Extension for colcon to recursively crawl for packages";
    homepage = "https://colcon.readthedocs.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
    downloadPage = "https://github.com/colcon/colcon-recursive-crawl";
  };
}
