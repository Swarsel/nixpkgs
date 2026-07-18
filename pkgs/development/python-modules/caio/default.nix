{
  lib,
  stdenv,
  fetchFromGitHub,
  aiomisc-pytest,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "caio";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "mosquito";
    repo = "caio";
    tag = finalAttrs.version;
    hash = "sha256-IeyksrYpLMc9PJjpYeaOgLx26CeVMoR/3r2RX66ucDs=";
  };

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isClang [ "-Wno-error=implicit-function-declaration" ]
  );

  nativeCheckInputs = [
    aiomisc-pytest
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "caio" ];

  meta = {
    description = "File operations with asyncio support";
    homepage = "https://github.com/mosquito/caio";
    changelog = "https://github.com/mosquito/caio/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
