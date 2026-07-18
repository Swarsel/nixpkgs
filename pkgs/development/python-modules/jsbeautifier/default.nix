{
  lib,
  buildPythonPackage,
  editorconfig,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "jsbeautifier";
  version = "1.15.4";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-W7GNnvuTMdglc1+8U2DujxqsXlJ4AEKAOUOqf4VPdZI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    editorconfig
    six
  ];

  enabledTestPaths = [ "jsbeautifier/tests/testindentation.py" ];
  pyproject = true;
  pythonImportsCheck = [ "jsbeautifier" ];

  meta = {
    description = "JavaScript unobfuscator and beautifier";
    homepage = "http://jsbeautifier.org";
    changelog = "https://github.com/beautify-web/js-beautify/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ apeyroux ];
    mainProgram = "js-beautify";
  };
})
