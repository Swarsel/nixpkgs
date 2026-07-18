{
  lib,
  buildPythonPackage,
  fetchPypi,
  funcsigs,
  mako,
  numpy,
  pycuda,
  pyopencl,
  pytest-cov-stub,
  pytestCheckHook,
  sphinx,
  withCuda ? false,
  withOpenCL ? true,
}:

buildPythonPackage rec {
  pname = "reikna";
  version = "0.9.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uzIoGCkIINgmO+r0vAzmihS14GWv5ygakMz3tKIG3zA=";
  };

  propagatedBuildInputs = [
    mako
    numpy
    funcsigs
  ]
  ++ lib.optional withCuda pycuda
  ++ lib.optional withOpenCL pyopencl;

  # Requires device
  doCheck = false;

  nativeCheckInputs = [
    sphinx
    pytest-cov-stub
    pytestCheckHook
  ];

  format = "setuptools";

  meta = {
    description = "GPGPU algorithms for PyCUDA and PyOpenCL";
    homepage = "https://github.com/fjarri/reikna";
    license = lib.licenses.mit;
  };
}
