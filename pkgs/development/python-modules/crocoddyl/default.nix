{
  lib,
  crocoddyl,
  example-robot-data,
  ffmpeg,
  ipykernel,
  matplotlib,
  nbconvert,
  nbformat,
  python,
  pythonImportsCheckHook,
  scipy,
  toPythonModule,
  buildStandalone ? true,
}:
toPythonModule (
  crocoddyl.overrideAttrs (super: {
    pname = "py-${super.pname}";

    # those are used by CMake at configure/build time
    nativeBuildInputs = super.nativeBuildInputs ++ [
      python
    ];

    propagatedBuildInputs = [
      example-robot-data
    ]
    ++ super.propagatedBuildInputs
    ++ lib.optional buildStandalone crocoddyl;

    cmakeFlags = super.cmakeFlags ++ [
      (lib.cmakeBool "BUILD_PYTHON_INTERFACE" true)
      (lib.cmakeBool "BUILD_STANDALONE_PYTHON_INTERFACE" buildStandalone)
    ];

    nativeCheckInputs = [
      ffmpeg
      pythonImportsCheckHook
    ];

    checkInputs = [
      matplotlib
      nbconvert
      nbformat
      ipykernel
      scipy
    ];

    __darwinAllowLocalNetworking = true;

    pythonImportsCheck = [
      "crocoddyl"
    ];
  })
)
