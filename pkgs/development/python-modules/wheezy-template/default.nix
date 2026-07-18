{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "wheezy.template";
  version = "3.2.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-hknPXHGPPNjRAr0TYVosPaTntsjwQjOKZBCU+qFlIHw=";
  };

  format = "setuptools";
  pythonImportsCheck = [ "wheezy.template" ];

  meta = {
    description = "Lightweight template library";
    homepage = "https://wheezytemplate.readthedocs.io/en/latest/";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "wheezy.template";
  };
}
