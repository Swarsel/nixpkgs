{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "python-lorem";
  version = "1.3.0.post3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Vw1TKheXg+AkhksnmWUfdIo+Jt7X7m1pS2f0Kfe8pv0=";
    pname = "python_lorem";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "lorem"
  ];

  meta = {
    description = "Pythonic lorem ipsum generator";
    homepage = "https://github.com/JarryShaw/lorem";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ aleksana ];
  };
}
