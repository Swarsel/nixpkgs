{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hcloud,
  octodns,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage rec {
  pname = "octodns-hetzner";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "octodns";
    repo = "octodns-hetzner";
    tag = "v${version}";
    hash = "sha256-aWWT/LShHxWOfNhBr7vCeG9bA6yXEutO2NJic18szL8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    octodns
    requests
    hcloud
  ];

  pyproject = true;
  pythonImportsCheck = [ "octodns_hetzner" ];

  meta = {
    description = "Hetzner DNS provider for octoDNS";
    homepage = "https://github.com/octodns/octodns-hetzner/";
    changelog = "https://github.com/octodns/octodns-hetzner/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    teams = [ lib.teams.octodns ];
  };
}
