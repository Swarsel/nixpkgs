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
  pname = "octodns-desec";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "rootshell-labs";
    repo = "octodns-desec";
    tag = version;
    hash = "sha256-tRviqrNkKYWj4a3EWCJEco8AnzFuRkvSCzZ1HrSye/I=";
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
  pythonImportsCheck = [ "octodns_desec" ];

  meta = {
    description = "deSEC DNS provider for octoDNS";
    homepage = "https://github.com/rootshell-labs/octodns-desec";
    changelog = "https://github.com/rootshell-labs/octodns-desec/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    teams = [ lib.teams.octodns ];
  };
}
