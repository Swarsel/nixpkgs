{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "open-garage";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Danielhiversen";
    repo = "pyOpenGarage";
    rev = version;
    hash = "sha256-iJ7HcJhpTceFpHTUdNZOYDuxUWZGWPmZ9lxD3CyGvk8=";
  };

  propagatedBuildInputs = [
    aiohttp
    async-timeout
  ];

  # Project has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "opengarage" ];

  meta = {
    description = "Python module to communicate with opengarage.io";
    homepage = "https://github.com/Danielhiversen/pyOpenGarage";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
