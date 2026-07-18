{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
}:

buildPythonPackage rec {
  pname = "pypeg2";
  version = "2.15.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0v8ziaam2r637v94ra4dbjw6jzxz99gs5x4i585kgag1v204yb9b";
  };

  #https://bitbucket.org/fdik/pypeg/issues/36/test-failures-on-py35
  doCheck = !isPy3k;

  checkPhase = ''
    # The tests assume that test_xmlast does not run before test_pyPEG2.
    python -m unittest pypeg2.test.test_pyPEG2 pypeg2.test.test_xmlast
  '';

  format = "setuptools";

  meta = {
    description = "PEG parser interpreter in Python";
    homepage = "http://fdik.org/pyPEG";
    license = lib.licenses.gpl2;
  };
}
