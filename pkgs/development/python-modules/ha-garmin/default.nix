{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  curl-cffi,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ha-garmin";
  version = "0.1.29";

  src = fetchFromGitHub {
    owner = "cyberjunky";
    repo = "ha-garmin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mny9QnmgRaCFZf4pExdIGDlljw6nSPhU8kB9rzSHymg=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    curl-cffi
    pydantic
    requests
  ];

  disabledTests = [
    # Upstream test relies on a field not present in the test fixture
    "test_fetch_core_data_sleep_fields"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ha_garmin" ];

  meta = {
    description = "Python client for Garmin Connect API, designed for Home Assistant integration";
    homepage = "https://github.com/cyberjunky/ha-garmin";
    changelog = "https://github.com/cyberjunky/ha-garmin/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
