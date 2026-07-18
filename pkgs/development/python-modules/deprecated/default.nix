{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pythonAtLeast,
  setuptools_80,
  sphinxHook,
  wrapt,
}:

buildPythonPackage (finalAttrs: {
  pname = "deprecated";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "tantale";
    repo = "deprecated";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1mB9aRZOsaW7Mqcu1SWIYTusQ7MlMvUucdTyfu++Nx8=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [ sphinxHook ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools_80 ];
  dependencies = [ wrapt ];

  disabledTests = lib.optionals (pythonAtLeast "3.13") [
    # assertion text mismatch
    "test_classic_deprecated_class_method__warns"
    "test_sphinx_deprecated_class_method__warns"
  ];

  pyproject = true;
  pythonImportsCheck = [ "deprecated" ];

  meta = {
    description = "Python @deprecated decorator to deprecate old python classes, functions or methods";
    homepage = "https://github.com/tantale/deprecated";
    changelog = "https://github.com/laurent-laporte-pro/deprecated/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tilpner ];
  };
})
