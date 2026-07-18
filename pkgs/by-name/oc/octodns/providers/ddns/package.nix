{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  octodns,
  pytestCheckHook,
  requests,
  setuptools,
}:
buildPythonPackage rec {
  pname = "octodns-ddns";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "octodns";
    repo = "octodns-ddns";
    tag = "v${version}";
    hash = "sha256-mHcm2MlQUVju3+3aQ3DVaMvg5WmDUi5+4zgAEQP3kiA=";
  };

  env.OCTODNS_RELEASE = 1;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    octodns
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "octodns_ddns"
  ];

  meta = {
    description = "Simple Dynamic DNS source for octoDNS";
    homepage = "https://github.com/octodns/octodns-ddns";
    changelog = "https://github.com/octodns/octodns-ddns/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.provokateurin ];
    teams = [ lib.teams.octodns ];
  };
}
