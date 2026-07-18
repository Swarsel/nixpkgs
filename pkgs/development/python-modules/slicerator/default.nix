{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
}:

buildPythonPackage rec {
  pname = "slicerator";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-RAEKf1zYdoDAchO1yr6B0ftxJSlilD5Tc+59FGBdYEY=";
  };

  # run_tests.py not packaged with pypi release
  doCheck = false;

  checkPhase = ''
    ${python.interpreter} run_tests.py
  '';

  format = "setuptools";

  meta = {
    description = "Lazy-loading, fancy-sliceable iterable";
    homepage = "https://github.com/soft-matter/slicerator";
    license = lib.licenses.bsdOriginal;
    maintainers = [ ];
  };
}
