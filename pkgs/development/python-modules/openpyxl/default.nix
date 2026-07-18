{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  et-xmlfile,
  lxml,
  pandas,
  pillow,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "openpyxl";
  version = "3.1.5";

  src = fetchFromGitLab {
    owner = "openpyxl";
    repo = "openpyxl";
    tag = version;
    hash = "sha256-vp+TIWcHCAWlDaBcmC7w/kV7DZTZpa6463NusaJmqKo=";
    domain = "foss.heptapod.net";
  };

  nativeCheckInputs = [
    lxml
    pandas
    pillow
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ et-xmlfile ];

  disabledTests = [
    # lxml 6.0
    "test_iterparse"
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "openpyxl" ];

  meta = {
    description = "Python library to read/write Excel 2010 xlsx/xlsm files";
    homepage = "https://openpyxl.readthedocs.org";
    changelog = "https://foss.heptapod.net/openpyxl/openpyxl/-/blob/${version}/doc/changes.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lihop ];
  };
}
