{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytest-timeout,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "busypie";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "rockem";
    repo = "busypie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MIwME5QM0BDpYP9frraJP/1v0lTZpPzgbqAawpGAcU0=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-timeout
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "busypie" ];

  meta = {
    description = "Expressive busy wait for Python";
    homepage = "https://github.com/rockem/busypie";
    changelog = "https://github.com/rockem/busypie/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
