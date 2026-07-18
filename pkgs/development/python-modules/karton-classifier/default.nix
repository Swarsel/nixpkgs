{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  chardet,
  karton-core,
  pytestCheckHook,
  python-magic,
  setuptools,
  yara-python,
}:

buildPythonPackage (finalAttrs: {
  pname = "karton-classifier";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "CERT-Polska";
    repo = "karton-classifier";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YqxRiQ/kJheEJpYDqRNu9FydfnNX3OlGjgfX9Hwv+dM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    chardet
    karton-core
    python-magic
    yara-python
  ];

  disabledTests = [
    # Tests expecting results from a different version of libmagic
    "test_process_archive"
    "test_process_misc_csv"
    "test_process_runnable_win32_jar"
    "test_process_runnable_win32_lnk"
  ];

  pyproject = true;
  pythonImportsCheck = [ "karton.classifier" ];

  pythonRelaxDeps = [
    "chardet"
    "python-magic"
  ];

  meta = {
    description = "File type classifier for the Karton framework";
    homepage = "https://github.com/CERT-Polska/karton-classifier";
    changelog = "https://github.com/CERT-Polska/karton-classifier/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "karton-classifier";
  };
})
