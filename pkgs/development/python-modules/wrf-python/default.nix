{
  lib,
  fetchFromGitHub,
  basemap,
  buildPythonPackage,
  gfortran,
  netcdf4,
  numpy,
  python,
  setuptools,
  wrapt,
  xarray,
}:

buildPythonPackage rec {
  pname = "wrf-python";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "NCAR";
    repo = "wrf-python";
    tag = "v${version}";
    hash = "sha256-4k0HsWIthFdkXQ5ld65vEcUtR1vqwKuH08lgQdcDh2E=";
  };

  nativeBuildInputs = [ gfortran ];

  propagatedBuildInputs = [
    basemap
    numpy
    setuptools
    xarray
    wrapt
  ];

  nativeCheckInputs = [ netcdf4 ];

  checkPhase = ''
    runHook preCheck
    cd ./test/ci_tests
    ${python.interpreter} utests.py
    runHook postCheck
  '';

  format = "setuptools";
  pythonImportsCheck = [ "wrf" ];

  meta = {
    description = "WRF postprocessing library for Python";
    homepage = "http://wrf-python.rtfd.org";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mhaselsteiner ];
    # `ModuleNotFoundError: No module named 'distutils.msvccompiler'` on Python 3.11
    # `ModuleNotFoundError: No module named 'numpy.distutils'` on Python 3.12
    broken = true;
  };
}
