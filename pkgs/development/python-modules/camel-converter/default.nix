{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pydantic,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "camel-converter";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "sanders41";
    repo = "camel-converter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7CqwpmRGHK7mkYoIS+3NwMtEqtdtnLB463OO2Dp0Ut0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [ hatchling ];

  disabledTests = [
    # AttributeError: 'Test' object has no attribute 'model_dump'
    "test_camel_config"
  ];

  optional-dependencies = {
    pydantic = [ pydantic ];
  };

  pyproject = true;
  pythonImportsCheck = [ "camel_converter" ];

  meta = {
    description = "Module to convert strings from snake case to camel case or camel case to snake case";
    homepage = "https://github.com/sanders41/camel-converter";
    changelog = "https://github.com/sanders41/camel-converter/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
