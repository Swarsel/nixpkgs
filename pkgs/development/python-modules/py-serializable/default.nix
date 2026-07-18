{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  lxml,
  poetry-core,
  pytestCheckHook,
  xmldiff,
}:

buildPythonPackage rec {
  pname = "py-serializable";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "madpah";
    repo = "serializable";
    tag = "v${version}";
    hash = "sha256-nou1/80t9d2iKOdZZbcN4SI3dlvuC8T55KMCP/cDEEU=";
  };

  nativeCheckInputs = [
    lxml
    pytestCheckHook
    xmldiff
  ];

  build-system = [ poetry-core ];
  dependencies = [ defusedxml ];

  disabledTests = [
    # AssertionError: '<ns0[155 chars]itle>The Phoenix
    "test_serializable_no_defaultNS"
    "test_serializable_with_defaultNS"
  ];

  pyproject = true;
  pythonImportsCheck = [ "py_serializable" ];
  pythonRelaxDeps = [ "defusedxml" ];

  meta = {
    description = "Library to aid with serialisation and deserialisation to/from JSON and XML";
    homepage = "https://github.com/madpah/serializable";
    changelog = "https://github.com/madpah/serializable/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
