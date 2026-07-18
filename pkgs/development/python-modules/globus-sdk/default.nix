{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  flaky,
  pyjwt,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
}:

buildPythonPackage rec {
  pname = "globus-sdk";
  version = "4.3.1";

  src = fetchFromGitHub {
    owner = "globus";
    repo = "globus-sdk-python";
    tag = version;
    hash = "sha256-q3fYU8/r6IfoC55iN83jAGdFrhnXx7bTtvuf0R4RBv4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  checkInputs = [
    flaky
    responses
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    cryptography
    requests
    pyjwt
  ];

  pyproject = true;
  pythonImportsCheck = [ "globus_sdk" ];

  meta = {
    description = "Interface to Globus REST APIs, including the Transfer API and the Globus Auth API";
    homepage = "https://github.com/globus/globus-sdk-python";
    changelog = "https://github.com/globus/globus-sdk-python/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
  };
}
