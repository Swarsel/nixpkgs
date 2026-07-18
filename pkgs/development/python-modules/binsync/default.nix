{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  filelock,
  gitpython,
  libbs,
  prompt-toolkit,
  pycparser,
  pyside6,
  pytest-qt,
  pytestCheckHook,
  setuptools,
  sortedcontainers,
  toml,
  tqdm,
  wordfreq,
}:

buildPythonPackage rec {
  pname = "binsync";
  version = "5.11.0";

  src = fetchFromGitHub {
    owner = "binsync";
    repo = "binsync";
    tag = "v${version}";
    hash = "sha256-dRc/sF2eVCW1fX66PsF4xU1RbkSnn/sT/PFsRbvDpzY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-qt
    pyside6
  ];

  build-system = [ setuptools ];

  dependencies = [
    filelock
    gitpython
    libbs
    prompt-toolkit
    pycparser
    sortedcontainers
    toml
    tqdm
    wordfreq
  ];

  disabledTestPaths = [
    # Test tries to import angr-management
    "tests/test_angr_gui.py"
  ];

  optional-dependencies = {
    ghidra = [ pyside6 ];
  };

  pyproject = true;
  pythonImportsCheck = [ "binsync" ];

  meta = {
    description = "Reversing plugin for cross-decompiler collaboration, built on git";
    homepage = "https://github.com/binsync/binsync";
    changelog = "https://github.com/binsync/binsync/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ scoder12 ];
  };
}
