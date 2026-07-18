{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pythonOlder,
  setuptools,
  typing-extensions,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "readerwriterlock";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "elarivie";
    repo = "pyReaderWriterLock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8FC+4aDgGpF1BmOdlkFtMy7OfWdSmvn9fjKXSmmeJlg=";
  };

  # RuntimeError: There is no current event loop in thread 'MainThread'.
  doCheck = pythonOlder "3.14";

  nativeCheckInputs = [
    unittestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "readerwriterlock" ];
  unittestFlags = [ "tests" ];

  meta = {
    description = "Python 3 implementation of the Readers-writers problem";
    homepage = "https://github.com/elarivie/pyReaderWriterLock";
    changelog = "https://github.com/elarivie/pyReaderWriterLock/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
