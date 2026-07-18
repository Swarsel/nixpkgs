{
  lib,
  buildPythonPackage,
  fetchPypi,
  flask,
  httpx,
  lxml,
  pyparsing,
  pytestCheckHook,
  quixote,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "twill";
  version = "3.3.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-/ZT5ntn7YMafrD9/rWaOvROKo+CGFKSldG9jjH/eR0Q=";
  };

  nativeCheckInputs = [
    flask
    pytestCheckHook
    quixote
  ];

  build-system = [ setuptools ];

  dependencies = [
    httpx
    lxml
    pyparsing
  ];

  disabledTestPaths = [
    # pytidylib is abandoned
    "tests/test_tidy.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "twill" ];
  pythonRelaxDeps = [ "lxml" ];

  meta = {
    description = "Simple scripting language for Web browsing";
    homepage = "https://twill-tools.github.io/twill/";
    changelog = "https://github.com/twill-tools/twill/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mic92 ];
  };
})
