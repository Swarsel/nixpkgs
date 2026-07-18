{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "asyncio-throttle";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "hallazzang";
    repo = "asyncio-throttle";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u1qminadb29zh90k+L5KSK0jkU2OaWQocRBU1qpnUsM=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "asyncio_throttle" ];

  meta = {
    description = "Simple, easy-to-use throttler for asyncio";
    homepage = "https://github.com/hallazzang/asyncio-throttle";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
