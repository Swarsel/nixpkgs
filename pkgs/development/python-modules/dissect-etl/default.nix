{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  dissect-cstruct,
  dissect-util,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dissect-etl";
  version = "3.14";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.etl";
    tag = version;
    hash = "sha256-QmtFkzO57jLTQg16MawAgU7Vq8vgo7DkEDq+FEjnObs=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    defusedxml
    dissect-cstruct
    dissect-util
  ];

  disabledTests = [
    # Invalid header magic
    "test_sqlite"
    "test_empty"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.etl" ];

  meta = {
    description = "Dissect module implementing a parser for Event Trace Log (ETL) files";
    homepage = "https://github.com/fox-it/dissect.etl";
    changelog = "https://github.com/fox-it/dissect.etl/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
