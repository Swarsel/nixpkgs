{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "types-greenlet";
  version = "3.3.0.20251206";

  src = fetchPypi {
    inherit version;
    hash = "sha256-PhqzEqtxVMCO3C6BEPvwDZkgMj7cEUStRZt7AFIGMFU=";
    pname = "types_greenlet";
  };

  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "greenlet-stubs" ];

  meta = {
    description = "Typing stubs for greenlet";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
