{
  lib,
  buildPythonPackage,
  fetchPypi,
  roadlib,
  roadrecon,
  roadtx,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "roadtools";
  version = "0.0.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-RxRbcT9uhQBYRDqq1asYDIwqrji14zi7dwRuQLXJiyQ=";
  };

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    roadrecon
    roadlib
    roadtx
  ];

  pyproject = true;
  pythonImportsCheck = [ "roadtools" ];

  meta = {
    description = "Azure AD tooling framework";
    homepage = "https://github.com/dirkjanm/ROADtools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "roadtools";
  };
})
