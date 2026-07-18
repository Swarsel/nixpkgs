{
  lib,
  boost,
  coal,
  eigenpy,
  numpy,
  pylatexenc,
  pythonImportsCheckHook,
  toPythonModule,
  buildStandalone ? true,
}:
toPythonModule (
  coal.overrideAttrs (super: {
    pname = "py-${super.pname}";

    # those are used by CMake at configure/build time
    nativeBuildInputs = super.nativeBuildInputs ++ [
      numpy
      pylatexenc
    ];

    propagatedBuildInputs = [
      boost
      eigenpy
    ]
    ++ super.propagatedBuildInputs
    ++ lib.optional buildStandalone coal;

    cmakeFlags = super.cmakeFlags ++ [
      (lib.cmakeBool "BUILD_PYTHON_INTERFACE" true)
      (lib.cmakeBool "BUILD_STANDALONE_PYTHON_INTERFACE" buildStandalone)
    ];

    nativeCheckInputs = [
      pythonImportsCheckHook
    ];

    pythonImportsCheck = [
      "coal"
      "hppfcl"
    ];
  })
)
