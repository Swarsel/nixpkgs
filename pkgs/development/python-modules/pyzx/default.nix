{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ipywidgets,
  lark,
  numpy,
  pyperclip,
  pytestCheckHook,
  setuptools,
  tqdm,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pyzx";
  version = "0.10.4";

  src = fetchFromGitHub {
    owner = "zxcalc";
    repo = "pyzx";
    tag = "v${version}";
    hash = "sha256-ovc+7EACfGHbqGtBwD01h7TdSaifOGQK5E4+judVvSI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    ipywidgets
    lark
    numpy
    pyperclip
    tqdm
    typing-extensions
  ];

  disabledTestPaths = [
    # too expensive, and print results instead of reporting failures:
    "tests/long_scalar_test.py"
    "tests/long_test.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pyzx"
    "pyzx.circuit"
    "pyzx.graph"
    "pyzx.routing"
    "pyzx.local_search"
    "pyzx.scripts"
  ];

  pythonRelaxDeps = [
    "ipywidgets"
    "lark"
  ];

  meta = {
    description = "Library for quantum circuit rewriting and optimisation using the ZX-calculus";
    homepage = "https://github.com/zxcalc/pyzx";
    changelog = "https://github.com/zxcalc/pyzx/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
