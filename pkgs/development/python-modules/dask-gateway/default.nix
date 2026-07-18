{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  dask,
  distributed,
  hatchling,
}:

buildPythonPackage rec {
  pname = "dask-gateway";
  # update dask-gateway lock step with dask-gateway-server
  version = "2025.4.0";

  src = fetchFromGitHub {
    owner = "dask";
    repo = "dask-gateway";
    tag = version;
    hash = "sha256-Ezt5QkA21SDfuCMm+XY8d+xso8SDb4lmK/yd89Guu0Y=";
  };

  # tests requires cluster for testing
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    dask
    distributed
  ];

  pyproject = true;
  pythonImportsCheck = [ "dask_gateway" ];
  sourceRoot = "${src.name}/dask-gateway";

  meta = {
    description = "Client library for interacting with a dask-gateway server";
    homepage = "https://gateway.dask.org/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
