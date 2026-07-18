{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dissect-util";
  version = "3.24";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.util";
    tag = version;
    hash = "sha256-AbkIVtUbQkkui7H1ZT/xHl1tCfZMvlrbZ2RD3YJAh0E=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  disabledTests = [
    # File handling issue
    "test_cpio_formats"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.util" ];

  meta = {
    description = "Dissect module implementing various utility functions for the other Dissect modules";
    homepage = "https://github.com/fox-it/dissect.util";
    changelog = "https://github.com/fox-it/dissect.util/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "dump-nskeyedarchiver";
  };
}
