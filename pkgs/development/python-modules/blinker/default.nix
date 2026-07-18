{
  lib,
  buildPythonPackage,
  fetchPypi,
  # build-system
  flit-core,
  pytest-asyncio,
  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "blinker";
  version = "1.9.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tM4iZaer7ORefMiW6Y2+vmzq1WvPgFo9IxNtFF9URb8=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "blinker" ];

  meta = {
    description = "Fast Python in-process signal/event dispatching system";
    homepage = "https://github.com/pallets-eco/blinker/";
    changelog = "https://github.com/pallets-eco/blinker/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
