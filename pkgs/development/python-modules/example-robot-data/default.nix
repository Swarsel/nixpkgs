{
  lib,
  example-robot-data,
  pinocchio,
  python,
  pythonImportsCheckHook,
  toPythonModule,
  buildStandalone ? true,
}:
toPythonModule (
  example-robot-data.overrideAttrs (super: {
    pname = "py-${super.pname}";

    nativeBuildInputs = super.nativeBuildInputs ++ [
      python
    ];

    propagatedBuildInputs = [
      pinocchio
    ]
    ++ super.propagatedBuildInputs
    ++ lib.optional buildStandalone example-robot-data;

    cmakeFlags = super.cmakeFlags ++ [
      (lib.cmakeBool "BUILD_PYTHON_INTERFACE" true)
      (lib.cmakeBool "BUILD_STANDALONE_PYTHON_INTERFACE" buildStandalone)
    ];

    nativeCheckInputs = [
      pythonImportsCheckHook
    ];

    # The package expect to find an `example-robot-data/robots` folder somewhere
    # either in install prefix or in the sources
    # where it can find the meshes for unit tests
    preCheck = ''
      ln -s source ../../example-robot-data
    '';

    pythonImportsCheck = [ "example_robot_data" ];
  })
)
