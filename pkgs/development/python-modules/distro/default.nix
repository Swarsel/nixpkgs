{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "distro";
  version = "1.9.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-L6d8b9iUDxFu4da5Si+QsTteqNAZuYvIuv3KvN2b2+0=";
  };

  nativeBuildInputs = [ setuptools ];
  # tests are very targeted at individual linux distributions
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "distro" ];

  meta = {
    description = "Linux Distribution - a Linux OS platform information API";
    homepage = "https://github.com/nir0s/distro";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "distro";
  };
}
