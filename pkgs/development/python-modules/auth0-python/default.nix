{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  callee,
  cryptography,
  mock,
  poetry-core,
  poetry-dynamic-versioning,
  pyjwt,
  pyopenssl,
  pytestCheckHook,
  requests,
  urllib3,
}:

buildPythonPackage rec {
  pname = "auth0-python";
  version = "4.13.0";

  src = fetchFromGitHub {
    owner = "auth0";
    repo = "auth0-python";
    tag = version;
    hash = "sha256-+3c4fj2lv+HFhl3bJ1p1qPq602AG4oMecqE+FMpvjhI=";
  };

  nativeBuildInputs = [
    poetry-core
    poetry-dynamic-versioning
  ];

  propagatedBuildInputs = [
    aiohttp
    cryptography
    pyjwt
    pyopenssl
    requests
    urllib3
  ]
  ++ pyjwt.optional-dependencies.crypto;

  nativeCheckInputs = [
    aiohttp
    aioresponses
    callee
    mock
    pytestCheckHook
  ];

  disabledTests = [
    # Tries to ping websites (e.g. google.com)
    "can_timeout"
    "test_options_are_created_by_default"
    "test_options_are_used_and_override"
  ];

  pyproject = true;
  pythonImportsCheck = [ "auth0" ];
  pythonRelaxDeps = [ "cryptography" ];

  meta = {
    description = "Auth0 Python SDK";
    homepage = "https://github.com/auth0/auth0-python";
    changelog = "https://github.com/auth0/auth0-python/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
