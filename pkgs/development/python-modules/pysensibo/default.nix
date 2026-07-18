{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "pysensibo";
  version = "1.2.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Otk5W3VTbOAeZOVnXvW8VSxU1nHa8zUvmvduRTdlwVs=";
  };

  # No tests implemented
  doCheck = false;
  build-system = [ poetry-core ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pysensibo" ];

  meta = {
    description = "Module for interacting with Sensibo";
    homepage = "https://github.com/andrey-git/pysensibo";
    changelog = "https://github.com/andrey-git/pysensibo/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
