{
  lib,
  buildPythonPackage,
  fetchPypi,
  nvdlib,
  poetry-core,
  pydantic,
  pythonOlder,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "avidtools";
  version = "0.2.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-rYkA/+YfFhrS/WSx+jUWCsXDjp03aMoMiGdXeK3Kf4M=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    nvdlib
    pydantic
    typing-extensions
  ];

  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "avidtools" ];

  meta = {
    description = "Developer tools for AVID";
    homepage = "https://github.com/avidml/avidtools";
    changelog = "https://github.com/avidml/avidtools/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
