{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  octodns,
  pytestCheckHook,
  python-transip,
  setuptools,
}:
buildPythonPackage rec {
  pname = "octodns-transip";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "octodns";
    repo = "octodns-transip";
    tag = "v${version}";
    hash = "sha256-O9KhHjCdRt5lejwEqpv0OCwIXaqWVc2/u4ghzbYMiBA=";
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
    python-transip
  ];

  pyproject = true;

  pythonImportsCheck = [
    "octodns_transip"
  ];

  meta = {
    description = "octoDNS provider that targets Transip DNS";
    homepage = "https://github.com/octodns/octodns-transip";
    changelog = "https://github.com/octodns/octodns-transip/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.provokateurin ];
    teams = [ lib.teams.octodns ];
  };
}
