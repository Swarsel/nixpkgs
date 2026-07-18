{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
  requests,
  responses,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-backoff";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "python-backoff";
    repo = "backoff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Os20Gz+uWaEdUPPF9/tT7LNxbmN0W/tuzVZa3H+ZG2A=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    requests
    responses
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "backoff" ];

  meta = {
    description = "Python library providing function decorators for configurable backoff and retry";
    homepage = "https://github.com/python-backoff/backoff";
    changelog = "https://github.com/python-backoff/backoff/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
