{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "bitarray";
  version = "3.8.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Pq442v/XfJYhroDBaTLuo/s6SvFB+3zHJNStk+/5IQ0=";
  };

  checkPhase = ''
    cd $out
    ${python.interpreter} -c 'import bitarray; bitarray.test()'
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "bitarray" ];

  meta = {
    description = "Efficient arrays of booleans";
    homepage = "https://github.com/ilanschnell/bitarray";
    changelog = "https://github.com/ilanschnell/bitarray/raw/${version}/CHANGE_LOG";
    license = lib.licenses.psfl;
  };
}
