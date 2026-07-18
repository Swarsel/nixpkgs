{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  pillow,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ansi2image";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "helviojunior";
    repo = "ansi2image";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GWrVo1WJux+ATvG5F9J4WMDlI0XAeTpQg7NrkN1P4Co=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    colorama
    pillow
  ];

  enabledTestPaths = [ "tests/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "ansi2image" ];

  meta = {
    description = "Module to convert ANSI text to an image";
    homepage = "https://github.com/helviojunior/ansi2image";
    changelog = "https://github.com/helviojunior/ansi2image/blob/${finalAttrs.version}/CHANGELOG";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ansi2image";
  };
})
