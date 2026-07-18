{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dissect-cstruct";
  version = "4.7";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.cstruct";
    tag = version;
    hash = "sha256-eEaKGFpArg0p3+/I2dH3mQ+eNIVJ8KsUbRcw4Ecrl7g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.cstruct" ];

  meta = {
    description = "Dissect module implementing a parser for C-like structures";
    homepage = "https://github.com/fox-it/dissect.cstruct";
    changelog = "https://github.com/fox-it/dissect.cstruct/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
