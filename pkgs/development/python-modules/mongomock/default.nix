{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  packaging,
  pytestCheckHook,
  pytz,
  sentinels,
}:

buildPythonPackage rec {
  pname = "mongomock";
  version = "4.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-MmZ7eQZvq8EtTxfxao/XNhtfRDUgizujLCJuUiEqjDA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    packaging
    pytz
    sentinels
  ];

  pyproject = true;
  pythonImportsCheck = [ "mongomock" ];

  meta = {
    description = "Fake pymongo stub for testing simple MongoDB-dependent code";
    homepage = "https://github.com/mongomock/mongomock";
    changelog = "https://github.com/mongomock/mongomock/blob/${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ gador ];
  };
}
