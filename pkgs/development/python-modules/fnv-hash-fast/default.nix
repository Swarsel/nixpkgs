{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  fnvhash,
  poetry-core,
  pytest-codspeed,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "fnv-hash-fast";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "fnv-hash-fast";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yDEgVNaSqZ1AJivpkpinZznKlPEXH6mjXBe5aVp/3hQ=";
  };

  nativeCheckInputs = [
    pytest-codspeed
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    cython
    poetry-core
    setuptools
  ];

  dependencies = [ fnvhash ];
  pyproject = true;
  pythonImportsCheck = [ "fnv_hash_fast" ];

  meta = {
    description = "Fast version of fnv1a";
    homepage = "https://github.com/bdraco/fnv-hash-fast";
    changelog = "https://github.com/Bluetooth-Devices/fnv-hash-fast/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
