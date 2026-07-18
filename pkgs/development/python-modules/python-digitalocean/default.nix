{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jsonpickle,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-digitalocean";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "koalalorenzo";
    repo = "python-digitalocean";
    tag = "v${version}";
    hash = "sha256-CIYW6vl+IOO94VyfgTjJ3T13uGtz4BdKyVmE44maoLA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  preCheck = ''
    cd digitalocean
  '';

  build-system = [ setuptools ];

  dependencies = [
    jsonpickle
    requests
  ];

  # Test tries to access the network
  disabledTests = [ "TestFirewall" ];
  pyproject = true;
  pythonImportsCheck = [ "digitalocean" ];

  meta = {
    description = "Python API to manage Digital Ocean Droplets and Images";
    homepage = "https://github.com/koalalorenzo/python-digitalocean";
    changelog = "https://github.com/koalalorenzo/python-digitalocean/releases/tag/v${version}";
    license = with lib.licenses; [ lgpl3Only ];
    maintainers = with lib.maintainers; [ teh ];
  };
}
