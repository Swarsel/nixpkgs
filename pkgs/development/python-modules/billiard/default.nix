{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  psutil,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "billiard";
  version = "4.2.4";

  src = fetchFromGitHub {
    owner = "celery";
    repo = "billiard";
    tag = "v${version}";
    hash = "sha256-7DwS3fdYhMNVYR0RIoMFyxNpj56VrGlbF4mIgLKPrOQ=";
  };

  nativeCheckInputs = [
    psutil
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  disabledTests = [
    # time sensitive
    "test_on_ready_counter_is_synchronized"
  ];

  pyproject = true;
  pythonImportsCheck = [ "billiard" ];

  meta = {
    description = "Python multiprocessing fork with improvements and bugfixes";
    homepage = "https://github.com/celery/billiard";
    changelog = "https://github.com/celery/billiard/blob/${src.tag}/CHANGES.txt";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
