{
  lib,
  buildPythonPackage,
  fetchPypi,
  pastedeploy,
  plaster,
  pytestCheckHook,
  setuptools_80,
}:

buildPythonPackage rec {
  pname = "plaster-pastedeploy";
  version = "1.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-viYubS5BpyZIddqi/ihQy7BhVyi83JKCj9xyc244FBI=";
    pname = "plaster_pastedeploy";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools_80 ];

  dependencies = [
    plaster
    pastedeploy
  ];

  pyproject = true;

  meta = {
    description = "PasteDeploy binding to the plaster configuration loader";
    homepage = "https://github.com/Pylons/plaster_pastedeploy";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
