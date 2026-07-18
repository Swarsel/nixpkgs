{
  lib,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  latexcodec,
  # tests
  pytestCheckHook,
  pyyaml,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "pybtex";
  version = "0.25.1";

  src = fetchPypi {
    inherit version pname;
    sha256 = "sha256-nq+QJnx+g+Ilr4n+plw3Cvv2X0WCINOUap4wSeHspJE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    latexcodec
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "pybtex" ];

  meta = {
    description = "BibTeX-compatible bibliography processor written in Python";
    homepage = "https://pybtex.org/";
    changelog = "https://bitbucket.org/pybtex-devs/pybtex/src/master/CHANGES";
    license = lib.licenses.mit;
  };
}
