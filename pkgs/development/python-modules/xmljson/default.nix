{
  lib,
  buildPythonPackage,
  fetchPypi,
  lxml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "xmljson";
  version = "0.2.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-tBWOZqoeYu459/gOsv5PdnZwujwNXemARCDcU0J/3sg=";
  };

  nativeCheckInputs = [ lxml ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "xmljson" ];

  meta = {
    description = "Converts XML into dictionary structures and vice-versa";
    homepage = "https://github.com/sanand0/xmljson";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ rakesh4g ];
    mainProgram = "xml2json";
  };
})
