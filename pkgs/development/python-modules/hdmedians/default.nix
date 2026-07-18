{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  numpy,
  oldest-supported-numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "hdmedians";
  version = "0.14.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tHrssWdx4boHNlVyVdgK4CQLCRVr/0NDId5VmzWawtY=";
  };

  patches = [
    # https://github.com/daleroberts/hdmedians/pull/10
    ./replace-nose.patch
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'nose>=1.0'," ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    cd $out
  '';

  build-system = [
    cython
    oldest-supported-numpy
    setuptools
  ];

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "hdmedians" ];

  meta = {
    description = "High-dimensional medians";
    homepage = "https://github.com/daleroberts/hdmedians";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
