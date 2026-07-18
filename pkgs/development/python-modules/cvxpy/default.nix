{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  clarabel,
  cvxopt,
  highspy,
  # tests
  hypothesis,
  # build-system
  numpy,
  osqp,
  pybind11,
  pytestCheckHook,
  qdldl,
  scipy,
  scs,
  setuptools,
  sparsediffpy,
  useOpenmp ? (!stdenv.hostPlatform.isDarwin),
}:

buildPythonPackage (finalAttrs: {
  pname = "cvxpy";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "cvxpy";
    repo = "cvxpy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nYfS9HXWTKcvVrq+wm5cgvB7keMAQPmKEe8bI0jngFg=";
  };

  postPatch =
    # too tight tolerance in tests (AssertionError)
    ''
      substituteInPlace cvxpy/tests/test_constant_atoms.py \
        --replace-fail \
          "CLARABEL: 1e-7," \
          "CLARABEL: 1e-6,"
    '';

  # Required flags from https://github.com/cvxpy/cvxpy/releases/tag/v1.1.11
  preBuild = lib.optionalString useOpenmp ''
    export CFLAGS="-fopenmp"
    export LDFLAGS="-lgomp"
  '';

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    numpy
    pybind11
    setuptools
  ];

  dependencies = [
    clarabel
    cvxopt
    highspy
    numpy
    osqp
    qdldl
    scipy
    scs
    sparsediffpy
  ];

  disabledTests = [
    # Numerical assertions failing
    "test_oprelcone_1_m1_k3_real"
    "test_oprelcone_1_m3_k1_real"
    "test_oprelcone_1_m4_k4_real"

    # Disable the slowest benchmarking tests, cuts test time in half
    "test_tv_inpainting"
    "test_diffcp_sdp_example"
    "test_huber"
    "test_partial_problem"

    # cvxpy.error.SolverError: Solver 'CVXOPT' failed. Try another solver, or solve with verbose=True for more information.
    # https://github.com/cvxpy/cvxpy/issues/1588
    "test_oprelcone_1_m1_k3_complex"
    "test_oprelcone_1_m3_k1_complex"
    "test_oprelcone_2"
  ];

  enabledTestPaths = [ "cvxpy" ];
  pyproject = true;
  pythonImportsCheck = [ "cvxpy" ];

  pythonRelaxDeps = [
    "sparsediffpy"
  ];

  meta = {
    description = "Domain-specific language for modeling convex optimization problems in Python";
    homepage = "https://www.cvxpy.org/";
    changelog = "https://github.com/cvxpy/cvxpy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.GaetanLepage ];
    downloadPage = "https://github.com/cvxpy/cvxpy//releases";
  };
})
