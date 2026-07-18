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
  pname = "dissect-shellitem";
  version = "3.13";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.shellitem";
    tag = version;
    hash = "sha256-2pgKfvlYt8eZh6YsTx6Gqd0XvvzJtaSh0tnhVF+Z/50=";
  };

  # Windows-specific tests
  doCheck = false;
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
  pythonImportsCheck = [ "dissect.shellitem" ];

  meta = {
    description = "Dissect module implementing a parser for the Shellitem structures";
    homepage = "https://github.com/fox-it/dissect.shellitem";
    changelog = "https://github.com/fox-it/dissect.shellitem/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "parse-lnk";
  };
}
