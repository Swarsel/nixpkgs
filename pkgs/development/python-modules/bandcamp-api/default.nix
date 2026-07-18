{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  demjson3,
  fetchPypi,
  html5lib,
  lxml,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bandcamp-api";
  version = "0.2.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-7/WXMo7fCDMHATp4hEB8b7fNJWisUv06hbP+O878Phs=";
    pname = "bandcamp_api";
  };

  # upstream has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    demjson3
    html5lib
    lxml
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "bandcamp_api" ];

  meta = {
    description = "Obtains information from bandcamp.com";
    homepage = "https://github.com/RustyRin/bandcamp-api";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
