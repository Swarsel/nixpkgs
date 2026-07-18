{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  click-completion,
  # tests
  factory-boy,
  inquirer,
  notify-py,
  # build-system
  pbr,
  pendulum,
  prettytable,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  requests,
  setuptools,
  twine,
  validate-email,
  versionCheckHook,
}:

buildPythonPackage rec {
  pname = "toggl-cli";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "AuHau";
    repo = "toggl-cli";
    tag = "v${version}";
    hash = "sha256-f3s0XlhQZH9xC5xyM+e2VG9j1GK0qqWFm4Xy08Iwj/Q=";
  };

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    factory-boy
    pytest-cov-stub
    pytest-mock
    pytestCheckHook
    versionCheckHook
  ];

  build-system = [
    pbr
    setuptools
    twine
  ];

  dependencies = [
    click
    click-completion
    inquirer
    notify-py
    pbr
    pendulum
    prettytable
    requests
    setuptools
    validate-email
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # PermissionError: [Errno 1] Operation not permitted: '/etc/localtime'
    "tests/unit/cli/test_types.py"
  ];

  disabledTests = [
    "integration"
    "premium"
    "test_now"
    "test_parsing"
    "test_type_check"
  ];

  pyproject = true;
  pythonImportsCheck = [ "toggl" ];
  pythonRelaxDeps = true;
  versionCheckProgram = "${placeholder "out"}/bin/toggl";

  meta = {
    description = "Command line tool and set of Python wrapper classes for interacting with toggl's API";
    homepage = "https://toggl.uhlir.dev/";
    changelog = "https://github.com/AuHau/toggl-cli/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mmahut ];
    mainProgram = "toggl";
  };
}
