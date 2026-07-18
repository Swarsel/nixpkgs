{
  lib,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  fetchPypi,
  pillow,
}:

buildPythonPackage rec {
  pname = "python-family-hub-local";
  version = "0.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-bbOBlUJ4g+HOcJihEBAz3lsHR9Gn07z8st14FRFeJbc=";
    extension = "zip";
  };

  propagatedBuildInputs = [
    aiohttp
    async-timeout
    pillow
  ];

  # Module has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pyfamilyhublocal" ];

  meta = {
    description = "Module to accesse information from Samsung FamilyHub fridges locally";
    homepage = "https://github.com/Klathmon/python-family-hub-local";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
