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
  pname = "dissect-sql";
  version = "3.13";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.sql";
    tag = version;
    hash = "sha256-ShyirE5gsACziciYrJIWweNCCe+0U+qJrc/9jsc1PPo=";
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
    # Invalid header magic
    "test_sqlite"
    "test_empty"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.sql" ];

  meta = {
    description = "Dissect module implementing a parsers for the SQLite database file format";
    homepage = "https://github.com/fox-it/dissect.sql";
    changelog = "https://github.com/fox-it/dissect.sql/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
