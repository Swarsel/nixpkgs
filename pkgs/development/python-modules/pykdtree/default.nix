{
  lib,
  buildPythonPackage,
  # build-system
  cython,
  fetchPypi,
  numpy,
  # native dependencies
  openmp,
  # tests
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pykdtree";
  version = "1.4.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-2Rh5MP+4yCLFJZW2SUi0c0ZpTuKknicCQgtY90PXhvU=";
  };

  nativeBuildInputs = [
    cython
    numpy
    setuptools
  ];

  buildInputs = [ openmp ];
  propagatedBuildInputs = [ numpy ];
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # make sure we don't import pykdtree from the source tree
    mv pykdtree/test_tree.py .
    rm -rf pykdtree
  '';

  pyproject = true;

  meta = {
    description = "kd-tree implementation for fast nearest neighbour search in Python";
    homepage = "https://github.com/storpipfugl/pykdtree";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ psyanticy ];
  };
}
