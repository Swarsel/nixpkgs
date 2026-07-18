{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "throttler";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "uburuntu";
    repo = "throttler";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zcKhHA1PDEpfp+I/zHaGeg1x1F2LM0m7GxMLGDscCsw=";
  };

  checkInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  disabledTestPaths = [
    # time sensitive tests
    "tests/test_execution_timer.py"
  ];

  enabledTestPaths = [ "tests/" ];
  pyproject = true;

  meta = {
    description = "Zero-dependency Python package for easy throttling with asyncio support";
    homepage = "https://github.com/uburuntu/throttler";
    changelog = "https://github.com/uburuntu/throttler/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ renatoGarcia ];
  };
})
