{
  lib,
  fetchFromGitHub,
  backoff,
  buildPythonPackage,
  gitpython,
  pip,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "versionfinder";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "jantman";
    repo = "versionfinder";
    rev = version;
    hash = "sha256-aa2bRGn8Hn7gpEMUM7byh1qZVsqvJeMXomnwCj2Xu5o=";
  };

  nativeCheckInputs = [
    pip
    pytestCheckHook
    requests
  ];

  build-system = [ setuptools ];

  dependencies = [
    gitpython
    backoff
  ];

  disabledTestPaths = [
    # Acceptance tests use the network
    "versionfinder/tests/test_acceptance.py"
  ];

  disabledTests = [
    # Tests are out-dated
    "TestFindPipInfo"
  ];

  pyproject = true;
  pythonImportsCheck = [ "versionfinder" ];

  meta = {
    description = "Find the version of another package, whether installed via pip, setuptools or git";
    homepage = "https://github.com/jantman/versionfinder";
    changelog = "https://github.com/jantman/versionfinder/blob/${version}/CHANGES.rst";
    license = lib.licenses.agpl3Plus;
  };
}
