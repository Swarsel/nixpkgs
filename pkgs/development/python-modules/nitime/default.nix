{
  lib,
  stdenv,
  buildPythonPackage,
  cython,
  fetchPypi,
  matplotlib,
  networkx,
  nibabel,
  numpy,
  pytest-cov-stub,
  pytestCheckHook,
  scipy,
  setuptools,
  setuptools-scm,
  wheel,
}:

buildPythonPackage rec {
  pname = "nitime";
  version = "0.12.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Esv0iLBlXcBaoYoMpZgt6XAwJgTkYfyS6H69m3U5tv8=";
  };

  nativeBuildInputs = [
    cython
    setuptools
    setuptools-scm
    wheel
  ];

  propagatedBuildInputs = [
    numpy
    scipy
    matplotlib
    networkx
    nibabel
  ];

  doCheck = !stdenv.hostPlatform.isDarwin; # tests hang indefinitely

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  disabledTests = [
    # [doctest] nitime.tests.test_timeseries.test_UniformTime_repr
    # Expected:
    #     UniformTime([    0.,  1000.,  2000.,  3000.,  4000.], time_unit='ms')
    # Got:
    #     UniformTime([   0., 1000., 2000., 3000., 4000.], time_unit='ms')
    "test_UniformTime_repr"
  ];

  pyproject = true;
  pythonImportsCheck = [ "nitime" ];

  meta = {
    description = "Algorithms and containers for time-series analysis in time and spectral domains";
    homepage = "https://nipy.org/nitime";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.bcdarwin ];
  };
}
