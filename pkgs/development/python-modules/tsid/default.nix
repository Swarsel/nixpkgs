{
  lib,
  pinocchio,
  python,
  pythonImportsCheckHook,
  toPythonModule,
  tsid,
  buildStandalone ? true,
}:
toPythonModule (
  tsid.overrideAttrs (super: {
    pname = "py-${super.pname}";

    # those are used by CMake at configure/build time
    nativeBuildInputs = super.nativeBuildInputs ++ [
      python
    ];

    propagatedBuildInputs = [
      pinocchio
    ]
    ++ super.propagatedBuildInputs
    ++ lib.optional buildStandalone tsid;

    cmakeFlags = super.cmakeFlags ++ [
      (lib.cmakeBool "BUILD_PYTHON_INTERFACE" true)
      (lib.cmakeBool "BUILD_STANDALONE_PYTHON_INTERFACE" buildStandalone)
    ];

    nativeCheckInputs = [
      pythonImportsCheckHook
    ];

    pythonImportsCheck = [
      "tsid"
    ];
  })
)
