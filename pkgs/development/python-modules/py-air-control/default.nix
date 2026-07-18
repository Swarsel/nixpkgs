{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  coapthon3,
  pycryptodomex,
  setuptools,
}:

buildPythonPackage rec {
  pname = "py-air-control";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "rgerganov";
    repo = "py-air-control";
    tag = "v${version}";
    hash = "sha256-3Qk1cmF31vJhUEckjfbYM9IDgD+gVkZtQlXel8iP/b8=";
  };

  # tests sometimes hang forever on tear-down
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pycryptodomex
    coapthon3
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyairctrl" ];

  meta = {
    description = "Command Line App for Controlling Philips Air Purifiers";
    homepage = "https://github.com/rgerganov/py-air-control";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ urbas ];
  };
}
