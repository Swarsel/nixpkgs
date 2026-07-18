{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  msgpack,
  numpy,
  python,
}:

buildPythonPackage rec {
  pname = "msgpack-numpy";
  version = "0.4.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xmfTGAUTQi+cdUW+XuxdKW3Ls1fgb3LtOcxoN5dVbmk=";
  };

  buildInputs = [ cython ];

  propagatedBuildInputs = [
    msgpack
    numpy
  ];

  checkPhase = ''
    ${python.interpreter} msgpack_numpy.py
  '';

  format = "setuptools";

  meta = {
    description = "Numpy data type serialization using msgpack";
    homepage = "https://github.com/lebedov/msgpack-numpy";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
