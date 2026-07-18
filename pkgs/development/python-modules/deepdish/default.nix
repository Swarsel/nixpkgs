{
  lib,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  numpy,
  scipy,
  # build-system
  setuptools,
  tables,
}:

buildPythonPackage rec {
  pname = "deepdish";
  version = "0.3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-av86vvaTzsNEOPGD8p0aLZhiq6J7uVnU8k1W4AfkH/M=";
  };

  postPatch = ''
    substituteInPlace deepdish/core.py \
      --replace-fail "np.ComplexWarning" "np.exceptions.ComplexWarning"
  '';

  # nativeCheckInputs = [
  #   pandas
  # ];
  # The tests are broken: `ModuleNotFoundError: No module named 'deepdish.six.conf'`
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    scipy
    tables
  ];

  pyproject = true;
  pythonImportsCheck = [ "deepdish" ];

  meta = {
    description = "Flexible HDF5 saving/loading and other data science tools from the University of Chicago";
    homepage = "https://github.com/uchicago-cs/deepdish";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ndl ];
    mainProgram = "ddls";
  };
}
