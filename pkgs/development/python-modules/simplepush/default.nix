{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  cryptography,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "simplepush";
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "simplepush";
    repo = "simplepush-python";
    tag = "v${version}";
    hash = "sha256-DvDPihhx1rzJN6iQP5rHluplJ1AaN0b/glcd+tZCues=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    aiohttp
    cryptography
    requests
  ];

  # Module has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "simplepush" ];

  meta = {
    description = "Module to send push notifications via Simplepush";
    homepage = "https://github.com/simplepush/simplepush-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
