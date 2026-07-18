{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docutils,
  geographiclib,
  pytest7CheckHook,
  pythonAtLeast,
  pytz,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "geopy";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "geopy";
    repo = "geopy";
    tag = finalAttrs.version;
    hash = "sha256-mlOXDEtYry1IUAZWrP2FuY/CGliUnCPYLULnLNN0n4Y=";
  };

  nativeCheckInputs = [
    docutils
    pytest7CheckHook
    pytz
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ geographiclib ];
  disabledTestPaths = lib.optionals (pythonAtLeast "3.12") [ "test/test_init.py" ];

  disabledTests = [
    # ignore --skip-tests-requiring-internet flag
    "test_user_agent_default"
  ];

  pyproject = true;
  pytestFlags = [ "--skip-tests-requiring-internet" ];
  pythonImportsCheck = [ "geopy" ];

  meta = {
    description = "Python Geocoding Toolbox";
    homepage = "https://github.com/geopy/geopy";
    changelog = "https://github.com/geopy/geopy/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [ mit ];
    maintainers = [ ];
  };
})
