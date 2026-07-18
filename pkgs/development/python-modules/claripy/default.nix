{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cachetools,
  decorator,
  pysmt,
  pytestCheckHook,
  setuptools,
  typing-extensions,
  z3-solver,
}:

buildPythonPackage rec {
  pname = "claripy";
  version = "9.2.193";

  src = fetchFromGitHub {
    owner = "angr";
    repo = "claripy";
    tag = "v${version}";
    hash = "sha256-nZ7ORbhi0R79pcHpkx/lRVdfUsoutCqU+zHX8AICTUE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    cachetools
    decorator
    pysmt
    typing-extensions
    z3-solver
  ]
  ++ z3-solver.requiredPythonModules;

  pyproject = true;
  pythonImportsCheck = [ "claripy" ];
  # z3 does not provide a dist-info, so python-runtime-deps-check will fail
  pythonRemoveDeps = [ "z3-solver" ];

  meta = {
    description = "Python abstraction layer for constraint solvers";
    homepage = "https://github.com/angr/claripy";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
  };
}
