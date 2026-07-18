{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  pytestCheckHook,
  pyyaml,
  requests,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pynetbox";
  version = "7.8.0";

  src = fetchFromGitHub {
    owner = "netbox-community";
    repo = "pynetbox";
    tag = "v${version}";
    hash = "sha256-vHtKWiaIb1dwzXaFDqDQ3iWCHYtCqOJD5PMKigXbHtU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    packaging
    requests
  ];

  disabledTestPaths = [
    # requires docker for integration test
    "tests/integration"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pynetbox" ];

  meta = {
    description = "API client library for Netbox";
    homepage = "https://github.com/netbox-community/pynetbox";
    changelog = "https://github.com/netbox-community/pynetbox/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
