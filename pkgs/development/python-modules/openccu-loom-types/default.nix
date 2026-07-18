{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  datamodel-code-generator,
  pydantic,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "openccu-loom-types";
  version = "0.1.53";

  src = fetchFromGitHub {
    owner = "SukramJ";
    repo = "openccu-loom-types";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WoNB/xYE24qfmCSflWqgPp9FVDdCTAdOylOiOL5byMI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "openccu_loom_types" ];

  meta = {
    description = "Generated Pydantic / enum types for the openccu-loom REST + WebSocket contract";
    homepage = "https://github.com/SukramJ/openccu-loom-types";
    changelog = "https://github.com/SukramJ/openccu-loom-types/blob/${finalAttrs.src.tag}/changelog.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
