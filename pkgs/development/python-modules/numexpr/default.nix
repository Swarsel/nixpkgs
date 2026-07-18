{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "numexpr";
  version = "2.14.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-S+ALEIbHt6XDLjFVgSK3uAJD/gmFebFwln2oPzFStIs=";
  };

  preBuild = ''
    # Remove existing site.cfg, use the one we built for numpy
    ln -s ${numpy.cfg} site.cfg
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    pushd $out
  '';

  postCheck = ''
    popd
  '';

  build-system = [
    setuptools
    numpy
  ];

  dependencies = [ numpy ];

  disabledTests = [
    # fails on computers with more than 8 threads
    # https://github.com/pydata/numexpr/issues/479
    "test_numexpr_max_threads_empty_string"
    "test_omp_num_threads_empty_string"
  ];

  pyproject = true;
  pythonImportsCheck = [ "numexpr" ];

  meta = {
    description = "Fast numerical array expression evaluator for NumPy";
    homepage = "https://github.com/pydata/numexpr";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
