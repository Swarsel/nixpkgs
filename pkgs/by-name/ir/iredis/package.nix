{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "iredis";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "laixintao";
    repo = "iredis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m8XDNzHgMWBgcN3AyFlb8K/UNXbGhH4toKBiX5Q4/QY=";
  };

  nativeCheckInputs = with python3Packages; [
    freezegun
    pexpect
    pytestCheckHook
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    click
    configobj
    mistune
    packaging
    prompt-toolkit
    pygments
    python-dateutil
    redis
  ];

  disabledTestPaths = [
    # Fails on sandbox
    "tests/unittests/test_client.py"
    "tests/unittests/test_render_functions.py::test_render_unixtime_config_raw"
    "tests/unittests/test_render_functions.py::test_render_time"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Flaky tests
    "tests/unittests/test_entry.py::test_command_shell_options_higher_priority"
    "tests/unittests/test_utils.py::test_timer"
  ];

  enabledTestPaths = [
    # Only execute unittests, because cli tests require a running Redis
    "tests/unittests/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "iredis" ];

  pythonRelaxDeps = [
    "packaging"
    "redis"
  ];

  meta = {
    description = "Terminal Client for Redis with AutoCompletion and Syntax Highlighting";
    homepage = "https://iredis.xbin.io/";
    changelog = "https://github.com/laixintao/iredis/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ phanirithvij ];
    mainProgram = "iredis";
  };
})
