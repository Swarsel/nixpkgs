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
  pname = "dissect-thumbcache";
  version = "1.11";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.thumbcache";
    tag = version;
    hash = "sha256-yZAowAPQGfYl8RcCcnR5yPiiaY2s7LykRqgVeKThkpk=";
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

  disabledTests = [
    # Don't run Windows related tests
    "windows"
    "test_index_type"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.thumbcache" ];

  meta = {
    description = "Dissect module implementing a parser for the Windows thumbcache";
    homepage = "https://github.com/fox-it/dissect.thumbcache";
    changelog = "https://github.com/fox-it/dissect.thumbcache/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
