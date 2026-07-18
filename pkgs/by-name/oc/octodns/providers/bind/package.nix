{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dnspython,
  octodns,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "octodns-bind";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "octodns";
    repo = "octodns-bind";
    tag = "v${version}";
    hash = "sha256-ezLaNeqJoi3fcfwQFkiEyYUSlw7cTCikmv0qmPTzrvI=";
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
    dnspython
  ];

  pyproject = true;
  pythonImportsCheck = [ "octodns_bind" ];

  meta = {
    description = "RFC compliant (Bind9) provider for octoDNS";
    homepage = "https://github.com/octodns/octodns-bind";
    changelog = "https://github.com/octodns/octodns-bind/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    teams = [ lib.teams.octodns ];
  };
}
