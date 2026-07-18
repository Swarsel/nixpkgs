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
  pname = "dissect-esedb";
  version = "3.18";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.esedb";
    tag = version;
    hash = "sha256-1TWwZ+ZE+6559qNir1T9kaMg667TRK1rm4FestZgqbY=";
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
  pythonImportsCheck = [ "dissect.esedb" ];

  meta = {
    description = "Dissect module implementing a parser for Microsofts Extensible Storage Engine Database (ESEDB)";
    homepage = "https://github.com/fox-it/dissect.esedb";
    changelog = "https://github.com/fox-it/dissect.esedb/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
