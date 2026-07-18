{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
  pythonRelaxDepsHook,
  requests,
  requests-mock,
}:

buildPythonPackage rec {
  pname = "synology-srm";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "aerialls";
    repo = "synology-srm";
    tag = "v${version}";
    hash = "sha256-qQxctw1UUs3jYve//irBni8rNKeld5u/bVtOwD2ofEQ=";
  };

  nativeBuildInputs = [
    pythonRelaxDepsHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "synology_srm"
  ];

  pythonRelaxDeps = [
    "requests"
  ];

  meta = {
    description = "Python 3 library for Synology SRM (Router Manager)";
    homepage = "https://github.com/aerialls/synology-srm";
    changelog = "https://github.com/aerialls/synology-srm/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
