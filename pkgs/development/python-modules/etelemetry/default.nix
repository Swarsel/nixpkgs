{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ci-info,
  ci-py,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "etelemetry";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "sensein";
    repo = "etelemetry-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UaE5JQhv2AtzXKY7YD2/g6Kj1igKhmnY3zlf1P9B/iQ=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace-fail "versioneer.get_version()" "'${finalAttrs.version}'"
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    ci-info
    ci-py
    requests
  ];

  disabledTests = [
    # RuntimeError: Connection to server could not be made
    # due to external network access
    "test_etrequest"
    "test_get_project"
    "test_check_available"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "etelemetry"
    "etelemetry.client"
    "etelemetry.config"
  ];

  meta = {
    description = "Lightweight python client to communicate with the etelemetry server";
    homepage = "https://github.com/sensein/etelemetry-client";
    changelog = "https://github.com/sensein/etelemetry-client/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
