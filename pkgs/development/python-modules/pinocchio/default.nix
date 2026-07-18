{
  lib,
  casadi,
  coal,
  matplotlib,
  pinocchio,
  pybind11,
  python,
  pythonImportsCheckHook,
  toPythonModule,
  buildStandalone ? true,
}:
toPythonModule (
  pinocchio.overrideAttrs (super: {
    pname = "py-${super.pname}";

    nativeBuildInputs = super.nativeBuildInputs ++ [
      python
    ];

    propagatedBuildInputs = [
      casadi
      coal
    ]
    ++ super.propagatedBuildInputs
    ++ lib.optional buildStandalone pinocchio;

    cmakeFlags = super.cmakeFlags ++ [
      (lib.cmakeBool "BUILD_PYTHON_INTERFACE" true)
      (lib.cmakeBool "BUILD_STANDALONE_PYTHON_INTERFACE" buildStandalone)
    ];

    nativeCheckInputs = super.nativeCheckInputs ++ [
      pythonImportsCheckHook
    ];

    checkInputs = super.checkInputs ++ [
      matplotlib
      pybind11
    ];

    pythonImportsCheck = [
      "pinocchio"
    ];
  })
)
