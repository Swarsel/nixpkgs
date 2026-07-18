{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "chardet";
  version = "5.2.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Gztv9HmoxBS8P6LAhSmVaVxKAm3NbQYzst0JLKOcHPc=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  disabledTests = [
    # flaky; https://github.com/chardet/chardet/issues/256
    "test_detect_all_and_detect_one_should_agree"
  ];

  pyproject = true;
  pythonImportsCheck = [ "chardet" ];

  meta = {
    description = "Universal encoding detector";
    homepage = "https://github.com/chardet/chardet";
    changelog = "https://github.com/chardet/chardet/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    mainProgram = "chardetect";
  };
})
