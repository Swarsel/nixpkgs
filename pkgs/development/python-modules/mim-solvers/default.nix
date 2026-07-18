{
  lib,
  # propagatedBuildInputs
  boost,
  crocoddyl,
  eigenpy,
  mim-solvers,
  osqp,
  proxsuite,
  # nativeCheckInputs
  pytest,
  # nativeBuildInputs
  python,
  pythonImportsCheckHook,
  scipy,
  toPythonModule,
  buildStandalone ? true,
}:
toPythonModule (
  mim-solvers.overrideAttrs (super: {
    pname = "py-${super.pname}";

    # this is used by CMake at configure/build time
    nativeBuildInputs = super.nativeBuildInputs ++ [
      python
    ];

    propagatedBuildInputs = [
      boost
      crocoddyl
      eigenpy
      osqp
      proxsuite
      scipy
    ]
    ++ super.propagatedBuildInputs
    ++ lib.optional buildStandalone mim-solvers;

    cmakeFlags = super.cmakeFlags ++ [
      (lib.cmakeBool "BUILD_PYTHON_INTERFACE" true)
      (lib.cmakeBool "BUILD_STANDALONE_PYTHON_INTERFACE" buildStandalone)
    ];

    nativeCheckInputs = super.nativeCheckInputs ++ [
      pythonImportsCheckHook
      pytest
    ];

    pythonImportsCheck = [
      "mim_solvers"
    ];
  })
)
