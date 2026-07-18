{
  lib,
  fetchFromGitHub,
  applyPatches,
  buildPythonPackage,
  # build-system
  cmake,
  # tests
  cvxopt,
  # dependencies
  jinja2,
  joblib,
  ninja,
  numpy,
  pybind11,
  pytestCheckHook,
  replaceVars,
  scikit-build-core,
  scipy,
  setuptools-scm,
  torch,
}:

let
  qdldl_src = fetchFromGitHub {
    hash = "sha256-qCeOs4UjZLuqlbiLgp6BMxvw4niduCPDOOqFt05zi2E=";
    owner = "osqp";
    repo = "qdldl";
    tag = "v0.1.8";
  };

  osqp_src = applyPatches {
    src = fetchFromGitHub {
      owner = "osqp";
      repo = "osqp";
      tag = "v1.0.0";
      hash = "sha256-BOAytzJzHcggncQzeDrXwJOq8B3doWERJ6CKIVg1yJY=";
    };

    patches = [
      (replaceVars ./dont-fetch-qdldl.patch {
        inherit qdldl_src;
      })
    ];
  };
in

buildPythonPackage (finalAttrs: {
  pname = "osqp";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "osqp";
    repo = "osqp-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xK7ljAwVwsmj84s5yxeU64nwT6N/Ec58aYjiUUOr4Ig=";
  };

  patches = [
    (replaceVars ./dont-fetch-osqp.patch {
      inherit osqp_src;
    })
  ];

  nativeCheckInputs = [
    cvxopt
    pytestCheckHook
    torch
  ];

  __structuredAttrs = true;

  build-system = [
    cmake
    ninja
    pybind11
    scikit-build-core
    setuptools-scm
  ];

  dependencies = [
    jinja2
    joblib
    numpy
    scipy
  ];

  disabledTestPaths = [
    # CalledProcessError
    # Try to invoke `python setup.py build_ext --inplace`
    "src/osqp/tests/codegen_matrices_test.py"
    "src/osqp/tests/codegen_vectors_test.py"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "osqp" ];

  meta = {
    description = "Operator Splitting QP Solver";

    longDescription = ''
      Numerical optimization package for solving problems in the form
        minimize        0.5 x' P x + q' x
        subject to      l <= A x <= u

      where x in R^n is the optimization variable
    '';

    homepage = "https://osqp.org/";
    changelog = "https://github.com/osqp/osqp-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      GaetanLepage
    ];

    downloadPage = "https://github.com/oxfordcontrol/osqp-python/releases";
  };
})
