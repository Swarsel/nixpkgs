{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch2,
  numpy,
  pandas,
  pytestCheckHook,
  scipy,
  setuptools,
  tables,
}:

buildPythonPackage rec {
  pname = "flammkuchen";
  version = "1.0.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-z68HBsU9J6oe8+YL4OOQiMYQRs3TZUDM+e2ssqo6BFI=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-/goNkiEBrcprywQYf2oKvGbu5j12hmalPuB45wNNt+I=";
      name = "numpy-v2-compat.patch";
      url = "https://github.com/portugueslab/flammkuchen/commit/c523ea78e10facd98d4893f045249c68bae17940.patch?full_index=1";
    })
  ];

  nativeCheckInputs = [
    pandas
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
    tables
  ];

  pyproject = true;

  meta = {
    description = "Flexible HDF5 saving/loading library forked from deepdish (University of Chicago) and maintained by the Portugues lab";
    homepage = "https://github.com/portugueslab/flammkuchen";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
