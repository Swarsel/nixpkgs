{
  lib,
  fetchFromGitHub,
  babel,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "py-moneyed";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "py-moneyed";
    repo = "py-moneyed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-k0ZbLwog6TYxKDLZV7eH1Br8buMPfpOkgp+pMN/qdB8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    babel
    typing-extensions
  ];

  disabledTests = [
    # babel has more currencies than defined in the package
    "test_all_babel_currencies"
  ];

  pyproject = true;
  pythonImportsCheck = [ "moneyed" ];

  meta = {
    description = "Provides Currency and Money classes for use in your Python code";
    homepage = "https://github.com/py-moneyed/py-moneyed";
    changelog = "https://github.com/py-moneyed/py-moneyed/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ kurogeek ];
  };
})
