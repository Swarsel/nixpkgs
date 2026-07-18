{
  lib,
  fetchFromGitHub,
  async-timeout,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "ld2410-ble";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "930913";
    repo = "ld2410-ble";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wQnE2hNT0UOnPJbHq1eayIO8g0XRZvEH6V19DL6RqoA=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    async-timeout
    bleak
    bleak-retry-connector
  ];

  pyproject = true;
  pythonImportsCheck = [ "ld2410_ble" ];

  meta = {
    description = "Library for the LD2410B modules from HiLinks";
    homepage = "https://github.com/930913/ld2410-ble";
    changelog = "https://github.com/930913/ld2410-ble/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
