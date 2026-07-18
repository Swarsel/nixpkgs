{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "pymetno";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "Danielhiversen";
    repo = "PyMetno";
    tag = version;
    hash = "sha256-0QODCJmGxgSKsTbsq4jsoP3cTy/0y6hq63j36bj7Dvo=";
  };

  propagatedBuildInputs = [
    aiohttp
    async-timeout
    xmltodict
  ];

  # Project has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "metno" ];

  meta = {
    description = "Library to communicate with the met.no API";
    homepage = "https://github.com/Danielhiversen/pyMetno/";
    changelog = "https://github.com/Danielhiversen/pyMetno/releases/tag/${version}";
    license = lib.licenses.mit;
  };
}
