{
  lib,
  stdenv,
  aligator,
  crocoddyl,
  ctestCheckHook,
  matplotlib,
  pinocchio,
  pytest,
  python,
  pythonImportsCheckHook,
  toPythonModule,
  buildStandalone ? true,
}:
toPythonModule (
  aligator.overrideAttrs (super: {
    pname = "py-${super.pname}";

    # this is used by CMake at configure/build time
    nativeBuildInputs = super.nativeBuildInputs ++ [
      python
    ];

    propagatedBuildInputs = [
      crocoddyl
      pinocchio
    ]
    ++ super.propagatedBuildInputs
    ++ lib.optional buildStandalone aligator;

    cmakeFlags = super.cmakeFlags ++ [
      (lib.cmakeBool "BUILD_PYTHON_INTERFACE" true)
      (lib.cmakeBool "BUILD_STANDALONE_PYTHON_INTERFACE" buildStandalone)
    ];

    nativeCheckInputs = [
      ctestCheckHook
      pythonImportsCheckHook
    ];

    checkInputs = super.checkInputs ++ [
      matplotlib
      pytest
    ];

    __darwinAllowLocalNetworking = true;

    disabledTests = [
      # known to work in pinocchio 3, but not 4.
      # ref https://github.com/Simple-Robotics/aligator/pull/404
      "aligator-test-py-constrained-dynamics"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # SIGTRAP
      "aligator-test-py-rollout"
    ];

    pythonImportsCheck = [
      "aligator"
    ];
  })
)
