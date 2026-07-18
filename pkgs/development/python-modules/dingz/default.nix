{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  click,
}:

buildPythonPackage rec {
  pname = "dingz";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "home-assistant-ecosystem";
    repo = "python-dingz";
    rev = version;
    hash = "sha256-bCytQwLWw8D1UkKb/3LQ301eDCkVR4alD6NHjTs6I+4=";
  };

  propagatedBuildInputs = [
    aiohttp
    async-timeout
    click
  ];

  # Project has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "dingz" ];

  meta = {
    description = "Python API for interacting with Dingz devices";
    homepage = "https://github.com/home-assistant-ecosystem/python-dingz";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "dingz";
  };
}
