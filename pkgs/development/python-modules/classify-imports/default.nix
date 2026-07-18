{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "classify-imports";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "asottile";
    repo = "classify-imports";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f5wZfisKz9WGdq6u0rd/zg2CfMwWvQeR8xZQNbD7KfU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "classify_imports" ];

  meta = {
    description = "Utilities for refactoring imports in python-like syntax";
    homepage = "https://github.com/asottile/classify-imports";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gador ];
  };
})
