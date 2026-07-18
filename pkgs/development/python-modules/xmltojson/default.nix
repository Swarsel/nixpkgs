{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "xmltojson";
  version = "2.0.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aKACInKt9wuPJjkYYXLICOlQLNA8C4UaZeB2BWHHgB0=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ poetry-core ];
  dependencies = [ xmltodict ];
  pyproject = true;
  pythonImportsCheck = [ "xmltojson" ];
  pythonRelaxDeps = [ "xmltodict" ];

  meta = {
    description = "Module and CLI tool to quickly convert xml text or files into json";
    homepage = "https://github.com/shanahanjrs/xmltojson";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
