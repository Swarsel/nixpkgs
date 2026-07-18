{
  lib,
  aiohttp,
  buildPythonPackage,
  cbor2,
  cryptography,
  fetchPypi,
  pyjwt,
  requests,
  setuptools,
  sqlalchemy,
}:

buildPythonPackage (finalAttrs: {
  pname = "roadlib";
  version = "1.7.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-al1FnLcKAFWRY43weXtsS8DN5pXCO1qFUw1vwLfZvGM=";
  };

  # Module has no test
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    cbor2
    cryptography
    pyjwt
    requests
    sqlalchemy
  ];

  optional-dependencies = {
    async = [ aiohttp ];
  };

  pyproject = true;
  pythonImportsCheck = [ "roadtools.roadlib" ];

  meta = {
    description = "ROADtools common components library";
    homepage = "https://pypi.org/project/roadlib/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
