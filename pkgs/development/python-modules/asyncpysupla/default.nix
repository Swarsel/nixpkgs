{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "asyncpysupla";
  version = "0.0.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-sRw4qAkHPIIc27FtxIe2vOvSK9PPBJYOZzDLgGYapDc=";
  };

  # Tests require API credentials and network access
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "asyncpysupla" ];

  meta = {
    description = "Simple Supla's OpenAPI async wrapper";
    homepage = "https://github.com/mwegrzynek/asyncpysupla";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
