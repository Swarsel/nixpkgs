{
  lib,
  fetchFromGitHub,
  aiohttp,
  backoff,
  buildPythonPackage,
  requests,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "energyid-webhooks";
  version = "0.0.14";

  src = fetchFromGitHub {
    owner = "EnergieID";
    repo = "energyid-webhooks-py";
    tag = "v${version}";
    hash = "sha256-43JfRBtRoERHYkhXjslxjohm8ypzgObRBmzbEwuzu7M=";
  };

  # upstream has no tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiohttp
    backoff
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "energyid_webhooks" ];

  meta = {
    description = "Light weight Python package to interface with EnergyID Webhooks";
    homepage = "https://github.com/EnergieID/energyid-webhooks-py";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
