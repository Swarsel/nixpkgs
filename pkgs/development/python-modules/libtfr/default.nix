{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  fftw,
  lapack,
  # Dependencies
  numpy,
  pkg-config,
  pkgconfig,
  # Check
  pytestCheckHook,
  # build-system
  setuptools_80,
}:
buildPythonPackage rec {
  pname = "libtfr";
  version = "2.1.9";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-GxRjkQ6ng2wNONRit8ZsCwWsVlXy//7taeU6np/5aU0=";
  };

  nativeBuildInputs = [
    pkg-config
    cython
  ];

  buildInputs = [
    fftw
    lapack
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools_80
  ];

  dependencies = [
    numpy
    pkgconfig
  ];

  pyproject = true;
  pythonImportsCheck = [ "libtfr" ];

  meta = {
    description = "fast multitaper conventional and reassignment spectrograms";
    homepage = "https://melizalab.github.io/libtfr/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      RossSmyth
    ];

    downloadPage = "https://github.com/melizalab/libtfr";
  };
}
