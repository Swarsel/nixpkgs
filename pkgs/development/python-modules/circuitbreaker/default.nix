{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "circuitbreaker";
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "fabfuel";
    repo = "circuitbreaker";
    tag = finalAttrs.version;
    hash = "sha256-7BpYGhha0PTYzsE9CsN4KxfJW/wm2i6V+uAeamBREBQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-mock
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "circuitbreaker" ];

  meta = {
    description = "Python Circuit Breaker implementation";
    homepage = "https://github.com/fabfuel/circuitbreaker";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
