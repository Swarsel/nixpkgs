{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  defusedxml,
  freezegun,
  mako,
  pycryptodomex,
  pydantic-settings,
  pyjwkest,
  # tests
  pytestCheckHook,
  # dependencies
  requests,
  responses,
  # build-system
  setuptools,
  testfixtures,
}:

buildPythonPackage rec {
  pname = "oic";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "CZ-NIC";
    repo = "pyoidc";
    tag = version;
    hash = "sha256-7qEK1HWLEGCKu+gDAfbyT1a+sM9fVOfjtkqZ33GWv6U=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    freezegun
    responses
    testfixtures
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    requests
    pycryptodomex
    pydantic-settings
    pyjwkest
    mako
    cryptography
    defusedxml
  ];

  pyproject = true;
  pythonImportsCheck = [ "oic" ];

  meta = {
    description = "OpenID Connect implementation in Python";
    homepage = "https://github.com/CZ-NIC/pyoidc";
    changelog = "https://github.com/CZ-NIC/pyoidc/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ veprbl ];
  };
}
