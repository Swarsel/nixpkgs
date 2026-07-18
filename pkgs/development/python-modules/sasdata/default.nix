{
  lib,
  buildPythonPackage,
  columnize,
  fetchPypi,
  h5py,
  hatch-requirements-txt,
  hatch-sphinx,
  hatch-vcs,
  hatchling,
  lxml,
  numpy,
  pytestCheckHook,
}:

let
  pname = "sasdata";
  version = "0.11.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-HIqEFN0Y+A4C6oF8NcI1puBt4SmyoNoAFobHQcYepnI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
    hatch-requirements-txt
    hatch-sphinx
    hatch-vcs
    h5py
    lxml
    numpy
  ];

  dependencies = [ columnize ];

  # need network
  disabledTestPaths = [
    "test/sasdataloader/utest_extension_registry.py::ExtensionRegistryTests::test_compare_remote_file_to_local"
    "test/sasdataloader/utest_sesans.py::sesans_reader::test_full_load"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sasdata" ];

  meta = {
    description = "Package for loading and handling SAS data";
    homepage = "https://github.com/SasView/sasdata";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ kyehn ];
  };
}
