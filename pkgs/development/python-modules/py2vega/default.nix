{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gast,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "py2vega";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "QuantStack";
    repo = "py2vega";
    tag = version;
    hash = "sha256-GU4mSOHsU/DPBdKFau6pOYQpaojXOfQIXrSG3skWr/I=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    gast
  ];

  pyproject = true;
  pythonRelaxDeps = [ "gast" ];

  meta = {
    description = "Python to Vega-expression transpiler";
    homepage = "https://github.com/QuantStack/py2vega";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
