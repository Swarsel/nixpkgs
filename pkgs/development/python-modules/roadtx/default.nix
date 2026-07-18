{
  lib,
  buildPythonPackage,
  fetchPypi,
  pycryptodomex,
  pyotp,
  requests,
  roadlib,
  selenium,
  selenium-wire-roadtx,
  setuptools,
  signxml,
}:

buildPythonPackage (finalAttrs: {
  pname = "roadtx";
  version = "1.22.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-2GIJAjLxOqy3E+5j1gnby8F5IAvdnChMT4Lfq5I5zeE=";
  };

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    pycryptodomex
    pyotp
    requests
    roadlib
    selenium
    selenium-wire-roadtx
    signxml
  ];

  pyproject = true;
  pythonImportsCheck = [ "roadtools.roadtx" ];

  meta = {
    description = "ROADtools Token eXchange";
    homepage = "https://pypi.org/project/roadtx/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
