{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pythonAtLeast,
}:
let
  pname = "paddle-bfloat";
  version = "0.1.7";
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit version;
    hash = "sha256-mrjQCtLsXOvqeHHMjuMx65FvMfZ2+wTh1ao9ZJE+9xw=";
    pname = "paddle_bfloat";
  };

  postPatch = ''
    sed '1i#include <memory>' -i bfloat16.cc # gcc12
    # replace deprecated function for python3.11
    substituteInPlace bfloat16.cc \
      --replace "Py_TYPE(&NPyBfloat16_Descr) = &PyArrayDescr_Type" "Py_SET_TYPE(&NPyBfloat16_Descr, &PyArrayDescr_Type)"
  '';

  propagatedBuildInputs = [ numpy ];
  # upstream has no tests
  doCheck = false;
  disabled = pythonAtLeast "3.12";
  format = "setuptools";
  pythonImportsCheck = [ "paddle_bfloat" ];

  meta = {
    description = "Paddle numpy bfloat16 package";
    homepage = "https://pypi.org/project/paddle-bfloat";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
