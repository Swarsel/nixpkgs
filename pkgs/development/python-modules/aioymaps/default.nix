{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aioymaps";
  version = "1.2.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tEl2tX/mB8uYTYj1YFDs/2sPXiv6897jCEmsFCWBXYg=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "aioymaps" ];

  meta = {
    description = "Python package fetch data from Yandex maps";
    homepage = "https://github.com/devbis/aioymaps";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
