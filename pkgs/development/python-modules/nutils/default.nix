{
  lib,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  flit-core,
  matplotlib,
  meshio,
  numpy,
  nutils-poly,
  pkgs,
  pytestCheckHook,
  scipy,
  stringly,
  treelog,
}:

buildPythonPackage rec {
  pname = "nutils";
  version = "9.2";

  src = fetchFromGitHub {
    owner = "evalf";
    repo = "nutils";
    tag = "v${version}";
    hash = "sha256-Q55nSs7SmB76vG8xJNaSu11vtSuWCXrNn0PRCkTWji4=";
  };

  nativeCheckInputs = [
    pkgs.graphviz
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ flit-core ];

  dependencies = [
    appdirs
    numpy
    nutils-poly
    stringly
    treelog
  ];

  disabledTests = [
    # Error: invalid value 'x' for farg: loading 'x' as float
    "run.test_badvalue"
    "choose.test_badvalue"
    # ModuleNotFoundError: No module named 'stringly'
    "picklability.test_basis"
    "picklability.test_domain"
    "picklability.test_geom"
  ];

  optional-dependencies = {
    export-mpl = [ matplotlib ];
    import-gmsh = [ meshio ];
    # TODO: matrix-mkl = [ mkl ];
    matrix-scipy = [ scipy ];
  };

  pyproject = true;
  pythonImportsCheck = [ "nutils" ];
  pythonRelaxDeps = [ "psutil" ];

  meta = {
    description = "Numerical Utilities for Finite Element Analysis";
    homepage = "https://www.nutils.org/";
    changelog = "https://github.com/evalf/nutils/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Scriptkiddi ];
  };
}
