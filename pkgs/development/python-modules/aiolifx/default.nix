{
  lib,
  fetchFromGitHub,
  async-timeout,
  bitstring,
  buildPythonPackage,
  click,
  ifaddr,
  inquirerpy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aiolifx";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "aiolifx";
    repo = "aiolifx";
    tag = version;
    hash = "sha256-v2001UY12HTi1pgugfRQSUg1R6uZAfVpwCASZZW9S0o=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    async-timeout
    bitstring
    click
    ifaddr
    inquirerpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiolifx" ];
  pythonRelaxDeps = [ "click" ];

  meta = {
    description = "Module for local communication with LIFX devices over a LAN";
    homepage = "https://github.com/aiolifx/aiolifx";
    changelog = "https://github.com/aiolifx/aiolifx/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ netixx ];
    mainProgram = "aiolifx";
  };
}
