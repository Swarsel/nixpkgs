{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "proliphix";
  version = "0.5.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Tf6gTRofZXY6ikrXBARgp6grzZGQMjvN5njT+7SRZNQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "proliphix" ];

  meta = {
    description = "API for Proliphix nt10e network thermostat";
    homepage = "https://github.com/sdague/proliphix";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
