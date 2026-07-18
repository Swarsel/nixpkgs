{
  lib,
  beaker,
  buildPythonPackage,
  fetchPypi,
  pyramid,
  pytest,
}:

buildPythonPackage rec {
  pname = "pyramid-beaker";
  version = "0.9";

  src = fetchPypi {
    inherit version;
    hash = "sha256-zMUT60z7W0Flfym25rKMor17O/n9qRMGoQKa7pLRz6U=";
    pname = "pyramid_beaker";
  };

  propagatedBuildInputs = [
    beaker
    pyramid
  ];

  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    # https://github.com/Pylons/pyramid_beaker/issues/29
    py.test -k 'not test_includeme' pyramid_beaker/tests.py
  '';

  format = "setuptools";

  meta = {
    description = "Beaker session factory backend for Pyramid";
    homepage = "https://docs.pylonsproject.org/projects/pyramid_beaker/en/latest/";
    license = lib.licenses.bsd3Modification;
    maintainers = [ ];
  };
}
