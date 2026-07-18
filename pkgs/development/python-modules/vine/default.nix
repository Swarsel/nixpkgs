{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "vine";
  version = "5.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-i2LpgdNcQQSSEc9ioKEkLYwe6b0Vuxls44rv1nmeYeA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  disabledTestPaths = [
    # https://github.com/celery/vine/issues/106
    "t/unit/test_synchronization.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "vine" ];

  meta = {
    description = "Python promises";
    homepage = "https://github.com/celery/vine";
    changelog = "https://github.com/celery/vine/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
})
