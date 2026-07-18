{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools_80,
}:

buildPythonPackage (finalAttrs: {
  pname = "roman";
  version = "5.2";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "roman";
    tag = finalAttrs.version;
    hash = "sha256-ZtwHlS3V18EqDXJxTTwfUdtOvyQg9GbSArV7sOs1b38=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools_80 ];
  enabledTestPaths = [ "src/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "roman" ];

  meta = {
    description = "Integer to Roman numerals converter";
    homepage = "https://pypi.org/project/roman/";
    changelog = "https://github.com/zopefoundation/roman/blob/${finalAttrs.version}/CHANGES.rst";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ sigmanificient ];
    mainProgram = "roman";
  };
})
