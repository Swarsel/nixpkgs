{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  celery,
  funcy,
  kombu,
  pytest-celery,
  pytest-mock,
  pytest-test-utils,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  shortuuid,
}:

buildPythonPackage (finalAttrs: {
  pname = "dvc-task";
  version = "0.40.2";

  src = fetchFromGitHub {
    owner = "iterative";
    repo = "dvc-task";
    tag = finalAttrs.version;
    hash = "sha256-bRQJLncxCigYPEtlvKjUtKqhcBkB7erEtoJQ30yGamE=";
  };

  nativeCheckInputs = [
    pytest-celery
    pytest-mock
    pytest-test-utils
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    celery
    funcy
    kombu
    shortuuid
  ];

  disabledTests = [
    # Test is flaky
    "test_start_already_exists"
    # Tests require a Docker setup
    "celery_setup_worker"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dvc_task" ];

  meta = {
    description = "Celery task queue used in DVC";
    homepage = "https://github.com/iterative/dvc-task";
    changelog = "https://github.com/iterative/dvc-task/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
