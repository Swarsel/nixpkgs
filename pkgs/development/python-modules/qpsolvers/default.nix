{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional dependencies
  clarabel,
  cvxopt,
  daqp,
  ecos,
  flit-core,
  gurobipy,
  highspy,
  jaxopt,
  numpy,
  osqp,
  piqp,
  proxsuite,
  quadprog,
  scipy,
  scs,
  unittestCheckHook,
}:
buildPythonPackage rec {
  pname = "qpsolvers";
  version = "4.12.0";

  src = fetchFromGitHub {
    owner = "qpsolvers";
    repo = "qpsolvers";
    tag = "v${version}";
    hash = "sha256-KUaDas2PIkTuy+Yi94vKm1P/n6QLPDcUXm8KjOq6JzI=";
  };

  nativeCheckInputs = [ unittestCheckHook ] ++ optional-dependencies.open_source_solvers;
  build-system = [ flit-core ];

  dependencies = [
    numpy
    scipy
  ];

  optional-dependencies = {
    # FIXME commented out solvers have not been packaged yet
    clarabel = [ clarabel ];
    cvxopt = [ cvxopt ];
    daqp = [ daqp ];
    ecos = [ ecos ];
    gurobi = [ gurobipy ];
    highs = [ highspy ];
    jaxopt = [ jaxopt ];

    open_source_solvers =
      with optional-dependencies;
      lib.flatten [
        clarabel
        cvxopt
        daqp
        ecos
        highs
        osqp
        piqp
        proxqp
        # qpalm
        quadprog
        scs
      ];

    # mosek = [ cvxopt mosek ];
    osqp = [ osqp ];
    piqp = [ piqp ];
    proxqp = [ proxsuite ];
    # qpalm = [ qpalm ];
    quadprog = [ quadprog ];
    scs = [ scs ];
  };

  pyproject = true;
  pythonImportsCheck = [ "qpsolvers" ];

  meta = {
    description = "Quadratic programming solvers in Python with a unified API";
    homepage = "https://github.com/qpsolvers/qpsolvers";
    changelog = "https://github.com/qpsolvers/qpsolvers/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ renesat ];
  };
}
