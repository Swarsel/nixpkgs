{
  lib,
  boost,
  ndcurves,
  pinocchio,
  python,
  pythonImportsCheckHook,
  toPythonModule,
  buildStandalone ? true,
}:
toPythonModule (
  ndcurves.overrideAttrs (super: {
    pname = "py-${super.pname}";

    # those are used by CMake at configure/build time
    nativeBuildInputs = super.nativeBuildInputs ++ [
      python
    ];

    propagatedBuildInputs = [
      boost
      pinocchio
    ]
    ++ super.propagatedBuildInputs
    ++ lib.optional buildStandalone ndcurves;

    cmakeFlags = super.cmakeFlags ++ [
      (lib.cmakeBool "BUILD_PYTHON_INTERFACE" true)
      (lib.cmakeBool "BUILD_STANDALONE_PYTHON_INTERFACE" buildStandalone)
    ];

    nativeCheckInputs = [
      pythonImportsCheckHook
    ];

    pythonImportsCheck = [
      "ndcurves"
    ];
  })
)
