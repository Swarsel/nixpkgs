{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  python-dateutil,
}:

buildPythonPackage rec {
  pname = "pyplaato";
  version = "0.0.19";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-hu45sofG7QiWZVCE1JrZZMBXWmQ/v0sK8QJlN+VBe+U=";
  };

  propagatedBuildInputs = [
    aiohttp
    python-dateutil
  ];

  # Module has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pyplaato" ];

  meta = {
    description = "Python API client for fetching Plaato data";
    homepage = "https://github.com/JohNan/pyplaato";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
