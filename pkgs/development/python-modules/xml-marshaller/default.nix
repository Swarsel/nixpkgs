{
  lib,
  buildPythonPackage,
  fetchPypi,
  lxml,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "xml-marshaller";
  version = "1.0.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-QvBALLDD8o5nZQ5Z4bembhadK6jcydWKQpJaSmGqqJM=";
    pname = "xml_marshaller";
  };

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    lxml
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "xml_marshaller" ];

  meta = {
    description = "This module allows one to marshal simple Python data types into a custom XML format";
    homepage = "https://www.python.org/community/sigs/current/xml-sig/";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ mazurel ];
  };
})
