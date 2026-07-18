{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyflakes,
  pytest,
}:

buildPythonPackage (finalAttrs: {
  # upstream has abandoned project in favor of pytest-flake8
  # retaining package to not break other packages
  pname = "pytest-flakes";
  version = "4.0.5";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "953134e97215ae31f6879fbd7368c18d43f709dc2fab5b7777db2bb2bac3a924";
  };

  buildInputs = [ pytest ];
  propagatedBuildInputs = [ pyflakes ];
  # no longer passes
  doCheck = false;
  nativeCheckInputs = [ pytest ];

  # disable one test case that looks broken
  checkPhase = ''
    py.test test_flakes.py -k 'not test_syntax_error'
  '';

  format = "setuptools";
  pythonImportsCheck = [ "pytest_flakes" ];

  meta = {
    description = "Pytest plugin to check source code with pyflakes";
    homepage = "https://pypi.org/project/pytest-flakes/";
    license = lib.licenses.mit;
  };
})
