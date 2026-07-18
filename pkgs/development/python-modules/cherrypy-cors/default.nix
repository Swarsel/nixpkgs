{
  lib,
  buildPythonPackage,
  cherrypy,
  fetchPypi,
  httpagentparser,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:
buildPythonPackage rec {
  pname = "cherrypy-cors";
  version = "1.7.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gzhM1mSnq4uat9SSb+lxOs/gvONmXuKBiaD6BLnyEtY=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [
    httpagentparser
    cherrypy
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "cherrypy_cors" ];

  meta = {
    description = "CORS support for CherryPy";
    homepage = "https://github.com/cherrypy/cherrypy-cors";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jpts ];
  };
}
