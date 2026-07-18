{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  pyserial-asyncio-fast,
  pytest-asyncio,
  pytestCheckHook,
  pythonOlder,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "enocean-async";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "henningkerstan";
    repo = "enocean-async";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VBBZwNPBgJ9rXUaAVtRzgdebeDtfJCt7R1zOu3Eom80=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    pyserial-asyncio-fast
  ];

  disabled = pythonOlder "3.14";

  disabledTestPaths = [
    # tests have broken imports, fixed in 0.12.4
    "tests/test_eep.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "enocean_async" ];

  meta = {
    description = "Async implementation of the EnOcean Serial Protocol Version 3";
    homepage = "https://github.com/henningkerstan/enocean-async";
    changelog = "https://github.com/henningkerstan/enocean-async/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
