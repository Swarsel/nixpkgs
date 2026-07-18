{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  # dependencies
  python-dateutil,
  # build-system
  rustPlatform,
  time-machine,
  tzdata,
}:

buildPythonPackage (finalAttrs: {
  pname = "pendulum";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "sdispater";
    repo = "pendulum";
    tag = finalAttrs.version;
    hash = "sha256-zpBymeYhCy+yu6RPhOuN5xOVk6928hd3+oRsfiBPPuY=";
  };

  patches = [
    # Fix the build on Darwin.
    #
    # <https://github.com/python-pendulum/pendulum/pull/979>
    ./delete-obsolete-cargo-toml.patch
  ];

  nativeBuildInputs = [
    rustPlatform.maturinBuildHook
    rustPlatform.cargoSetupHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
    time-machine
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-tC65lxI561ygOhBFujWzGk32XiQH6QB42nqboWSfQrg=";
    sourceRoot = "${finalAttrs.src.name}/rust";
  };

  cargoRoot = "rust";

  dependencies = [
    python-dateutil
    tzdata
  ];

  disabledTestPaths = [
    "tests/benchmarks"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # PermissionError: [Errno 1] Operation not permitted: '/etc/localtime'
    "tests/testing/test_time_travel.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pendulum" ];

  meta = {
    description = "Python datetimes made easy";
    homepage = "https://github.com/sdispater/pendulum";
    changelog = "https://github.com/sdispater/pendulum/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
