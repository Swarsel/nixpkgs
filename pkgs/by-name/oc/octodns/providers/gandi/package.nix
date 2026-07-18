{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  octodns,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage rec {
  pname = "octodns-gandi";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "octodns";
    repo = "octodns-gandi";
    tag = "v${version}";
    hash = "sha256-HUAWGJ4/v1YxaCskgIqh53M4nH9AlK9xHyGQhe5P6UE=";
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
  ];

  pyproject = true;
  pythonImportsCheck = [ "octodns_gandi" ];

  meta = {
    description = "Gandi v5 API provider for octoDNS";
    homepage = "https://github.com/octodns/octodns-gandi";
    changelog = "https://github.com/octodns/octodns-gandi/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.onny ];
    teams = [ lib.teams.octodns ];
  };
}
