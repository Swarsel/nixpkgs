{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
  pythonAtLeast,
  zc-buildout,
  zope-testrunner,
}:

buildPythonPackage rec {
  pname = "z3c-checkversions";
  version = "3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-VMGSlocgEddBrUT0A4ihtCdhSbirWYe9FmQ0QyOGOEs=";
    pname = "z3c.checkversions";
  };

  propagatedBuildInputs = [ zc-buildout ];
  nativeCheckInputs = [ zope-testrunner ];

  checkPhase = ''
    ${python.interpreter} -m zope.testrunner --test-path=src []
  '';

  # distutils usage
  disabled = pythonAtLeast "3.12";
  format = "setuptools";

  meta = {
    description = "Find newer package versions on PyPI";
    homepage = "https://github.com/zopefoundation/z3c.checkversions";
    changelog = "https://github.com/zopefoundation/z3c.checkversions/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
    mainProgram = "checkversions";
  };
}
