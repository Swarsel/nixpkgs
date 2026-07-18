{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "hightime";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "ni";
    repo = "hightime";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5WEr2tOxQap+otV8DCdIi3MkfHol4TU4qZXf4u2EQhY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [
    poetry-core
  ];

  # Test incompatible with datetime's integer type requirements
  disabledTests = [
    "test_datetime_arg_wrong_value"
  ];

  pyproject = true;
  pythonImportsCheck = [ "hightime" ];

  meta = {
    description = "Hightime Python API";
    homepage = "https://github.com/ni/hightime";
    changelog = "https://github.com/ni/hightime/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fsagbuya ];
  };
})
