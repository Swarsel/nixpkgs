{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  pyjwt,
  pytest-asyncio,
  pytest-httpx,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  time-machine,
}:

buildPythonPackage rec {
  pname = "httpx-auth";
  version = "0.23.1";

  src = fetchFromGitHub {
    owner = "Colin-b";
    repo = "httpx_auth";
    tag = "v${version}";
    hash = "sha256-wrPKUAGBzzuWNtwYtTtqOhb1xqYgc83uxn4rjbfDPmo=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [ httpx ];

  nativeCheckInputs = [
    pyjwt
    pytest-asyncio
    pytest-httpx
    pytestCheckHook
    time-machine
  ];

  __darwinAllowLocalNetworking = true;
  pyproject = true;

  pytestFlags = [
    # tests use a 6-byte HMAC key; pyjwt 2.11+ warns and upstream sets filterwarnings=error.
    "-Wignore::jwt.warnings.InsecureKeyLengthWarning"
  ];

  pythonImportsCheck = [ "httpx_auth" ];

  meta = {
    description = "Authentication classes to be used with httpx";
    homepage = "https://github.com/Colin-b/httpx_auth";
    changelog = "https://github.com/Colin-b/httpx_auth/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
