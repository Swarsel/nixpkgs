{
  lib,
  buildPythonPackage,
  dacite,
  diskcache,
  fetchPypi,
  jsonschema,
  pandas,
  poetry-core,
  pyarrow,
}:

buildPythonPackage rec {
  pname = "datashaper";
  version = "0.0.49";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Bb+6WWRHSmK91SWew/oBc9AeNlIItqSv9OoOYwlqdTM=";
  };

  # pypi tarball has no tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    dacite
    diskcache
    jsonschema
    pandas
    pyarrow
  ];

  pyproject = true;
  pythonImportsCheck = [ "datashaper" ];
  pythonRelaxDeps = [ "pyarrow" ];

  meta = {
    description = "Collection of utilities for doing lightweight data wrangling";
    homepage = "https://github.com/microsoft/datashaper/tree/main/python/datashaper";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
