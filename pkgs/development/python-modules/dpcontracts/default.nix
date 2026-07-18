{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage {
  pname = "dpcontracts";
  version = "0.6.0-unstable-2018-11-20";

  src = fetchFromGitHub {
    owner = "deadpixi";
    repo = "contracts";
    rev = "45cb8542272c2ebe095c6efb97aa9407ddc8bf3c";
    hash = "sha256-FygJPXo7lZ9tlfqY6KmPJ3PLIilMGLBr3013uj9hCEs=";
  };

  patches = [
    # Replacements in README.rst are necessary to check it with doctest
    ./fix-doctests.patch
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  enabledTestPaths = [
    "README.rst"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dpcontracts" ];

  meta = {
    description = "Provides a collection of decorators that makes it easy to write software using contracts";
    homepage = "https://github.com/deadpixi/contracts";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ gador ];
  };
}
