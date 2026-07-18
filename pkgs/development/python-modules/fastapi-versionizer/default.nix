{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  fastapi,
  # test dependencies
  httpx,
  natsort,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "fastapi-versionizer";
  version = "4.0.3";

  src = fetchFromGitHub {
    owner = "alexschimpf";
    repo = "fastapi-versionizer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Kj7tjy8TDV9MYhqJdVUBRohkIsYoqbQX5qnnkNBJPig=";
  };

  nativeCheckInputs = [
    httpx
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    fastapi
    natsort
  ];

  disabledTestPaths = [
    # openapi schema expectations drift with newer fastapi/pydantic
    "tests/test_simple.py"
    "tests/test_with_root_path.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "fastapi_versionizer"
    "fastapi_versionizer.versionizer"
  ];

  meta = {
    description = "API versionizer for FastAPI web applications";
    homepage = "https://github.com/alexschimpf/fastapi-versionizer";
    changelog = "https://github.com/alexschimpf/fastapi-versionizer/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      de11n
      despsyched
    ];

    downloadPage = "https://github.com/alexschimpf/fastapi-versionizer/releases/tag/${finalAttrs.src.tag}";
  };
})
