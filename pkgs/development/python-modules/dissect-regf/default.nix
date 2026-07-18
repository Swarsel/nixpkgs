{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dissect-cstruct,
  dissect-util,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dissect-regf";
  version = "3.14";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.regf";
    tag = version;
    hash = "sha256-bzRx+GwmT+tqCIIu/cJkbnwvkiGbZrtoUFNiirZFp28=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dissect-cstruct
    dissect-util
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.regf" ];

  meta = {
    description = "Dissect module implementing a parser for Windows registry file format";
    homepage = "https://github.com/fox-it/dissect.regf";
    changelog = "https://github.com/fox-it/dissect.regf/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
