{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
  # dependencies
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "dawg2-python";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "pymorphy2-fork";
    repo = "DAWG-Python";
    tag = version;
    hash = "sha256-45k7QmozbMt7qYdDFRSL5JDeEtqdMHBoEXXQkLDoGfE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "dawg_python"
  ];

  meta = {
    description = "Pure-python reader for DAWGs created by dawgdic C++ library or DAWG Python extension. Fork of  https://github.com/pytries/DAWG-Python";
    homepage = "https://github.com/pymorphy2-fork/DAWG-Python";
    changelog = "https://github.com/pymorphy2-fork/DAWG-Python/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
