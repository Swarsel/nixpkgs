{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  fastapi,
  httpx,
  jmespath,
  # build-system
  poetry-core,
  pydantic,
  # tests
  pytest-asyncio,
  pytestCheckHook,
  starlette,
  supervisor,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "model-hosting-container-standards";
  version = "0.1.14";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "model-hosting-container-standards";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3Nuus+MO3ASW7y5Bl7+04C2WvuSWG4HKNyQ+bx/uOw4=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    fastapi
    httpx
    jmespath
    pydantic
    starlette
    supervisor
  ];

  disabledTests = [
    # AssertionError: Server should have created restart log
    "test_continuous_restart_behavior"
    "test_startup_retry_limit"
  ];

  pyproject = true;
  pythonImportsCheck = [ "model_hosting_container_standards" ];

  pythonRemoveDeps = [
    # Declared as a runtime dependency, but not used in practice
    "setuptools"
  ];

  sourceRoot = "${finalAttrs.src.name}/python";

  meta = {
    description = "Standardized Python framework for seamless integration between ML frameworks (TensorRT-LLM, vLLM) and Amazon SageMaker hosting";
    homepage = "https://github.com/aws/model-hosting-container-standards/tree/main/python";
    changelog = "https://github.com/aws/model-hosting-container-standards/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
