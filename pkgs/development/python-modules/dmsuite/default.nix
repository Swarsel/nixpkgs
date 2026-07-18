{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dmsuite";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-IqLsHkGNgPz2yZm0QMyMMo6Mr2RsU2DPGxYpoNwC3fs=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    scipy
  ];

  # Slight precision error probably due to different BLAS backend on Darwin
  disabledTests = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    "test_cheb_scaled"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dmsuite" ];

  meta = {
    description = "Scientific library providing a collection of spectral collocation differentiation matrices";
    homepage = "https://github.com/labrosse/dmsuite";
    changelog = "https://github.com/labrosse/dmsuite/releases/tag/v${version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ loicreynier ];
  };
}
