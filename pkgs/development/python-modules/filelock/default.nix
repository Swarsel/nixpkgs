{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytest-asyncio,
  pytest-mock,
  pytest-timeout,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "filelock";
  version = "3.29.0";

  src = fetchFromGitHub {
    owner = "tox-dev";
    repo = "filelock";
    tag = version;
    hash = "sha256-efBEyjuCcLkHsfpG61eKN6ALk4QW4UMdNmD56rSgFLc=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytest-timeout
    pytestCheckHook
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  disabledTestPaths = [
    # Circular dependency with virtualenv
    "tests/test_virtualenv.py"
    # Very prone to timeouts on busy machines
    "tests/test_filelock.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "filelock" ];

  meta = {
    description = "Platform independent file lock for Python";
    homepage = "https://github.com/benediktschmitt/py-filelock";
    changelog = "https://github.com/tox-dev/py-filelock/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
