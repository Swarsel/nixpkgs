{
  lib,
  fetchFromGitHub,

  python3Packages,
  xacro,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "xacrodoc";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "adamheins";
    repo = "xacrodoc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zuyd+lVcrz06yEgapoTjOZP+mxfOsk52rQE33aKV0qI=";
  };

  strictDeps = true;

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    python3Packages.hatchling
  ];

  dependencies = [
    python3Packages.rospkg
    xacro
  ];

  optional-dependencies = {
    mujoco = [
      python3Packages.mujoco
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "xacrodoc"
  ];

  meta = {
    description = "Compile xacro files to plain URDF or MJCF from Python or the command line (no ROS required)";
    homepage = "https://github.com/adamheins/xacrodoc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nim65s ];
    mainProgram = "xacrodoc";
  };
})
