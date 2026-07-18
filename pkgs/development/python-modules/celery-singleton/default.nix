{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  celery,
  fetchpatch,
  poetry-core,
  pytest-celery,
  pytest-cov-stub,
  pytestCheckHook,
  redis,
}:

buildPythonPackage rec {
  pname = "celery-singleton";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "steinitzu";
    repo = "celery-singleton";
    rev = version;
    hash = "sha256-fHlakxxjYIADELZdxIj6rvsZ/+1QfnKvAg3w5cdzvDc=";
  };

  patches = [
    # chore(poetry): use poetry-core
    # https://github.com/steinitzu/celery-singleton/pull/54
    (fetchpatch {
      hash = "sha256-lXN4khwyL96pWyBS+iuSkGEkegv4HxYtym+6JUcPa94=";
      name = "use-poetry-core.patch";
      url = "https://github.com/steinitzu/celery-singleton/pull/54/commits/634a001c92a1dff1fae513fc95d733ea9b87e4cf.patch";
    })
  ];

  checkInputs = [
    pytestCheckHook
    pytest-celery
    pytest-cov-stub
  ];

  build-system = [ poetry-core ];

  dependencies = [
    celery
    redis
  ];

  # Tests require a running Redis backend
  disabledTests = [
    "TestLock"
    "TestUnlock"
    "TestClear"
    "TestSimpleTask"
    "TestRaiseOnDuplicateConfig"
    "TestUniqueOn"
  ];

  enabledTestPaths = [ "tests" ];
  pyproject = true;
  pythonImportsCheck = [ "celery_singleton" ];

  meta = {
    description = "Seamlessly prevent duplicate executions of celery tasks";
    homepage = "https://github.com/steinitzu/celery-singleton";
    changelog = "https://github.com/steinitzu/celery-singleton/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
  };
}
