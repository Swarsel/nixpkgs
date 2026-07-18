{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  ddt,
  mock-services,
  pytestCheckHook,
  python-dateutil,
  requests,
  requests-toolbelt,
  requests-unixsocket,
  setuptools,
  urllib3,
  ws4py,
}:

buildPythonPackage rec {
  pname = "pylxd";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "canonical";
    repo = "pylxd";
    tag = version;
    hash = "sha256-s3BdHZFNkXRT1MoLQCQ4+XPPFanZNZVgOSmYhJkx7JE=";
  };

  nativeCheckInputs = [
    ddt
    mock-services
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    cryptography
    python-dateutil
    requests
    requests-toolbelt
    requests-unixsocket
    urllib3
    ws4py
  ];

  disabledTestPaths = [
    "integration"
    "migration"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pylxd" ];
  pythonRelaxDeps = [ "urllib3" ];

  meta = {
    description = "Library for interacting with the LXD REST API";
    homepage = "https://pylxd.readthedocs.io/";
    changelog = "https://github.com/canonical/pylxd/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
