{
  lib,
  fetchFromGitHub,
  nixosTests,
  python3Packages,
}:

with python3Packages;
buildPythonApplication (finalAttrs: {
  pname = "pinnwand";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "supakeen";
    repo = "pinnwand";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Abj68lJn2qjL1jb+cVzkoc/RYKA6d5tYOPlEwqST0tY=";
  };

  nativeCheckInputs = [
    gitpython
    pytest-asyncio
    pytest-cov-stub
    pytest-html
    pytest-playwright
    pytestCheckHook
    tomli-w
    urllib3
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ pdm-backend ];

  dependencies = [
    click
    docutils
    pygments
    pygments-better-html
    python-dotenv
    sqlalchemy
    sqlalchemy-utc
    token-bucket
    tomli
    tornado
  ];

  disabledTestPaths = [
    # out-of-date browser tests
    "test/e2e"
    # click 8.2.0 exits with 2 instead of 0 when no args are passed
    "test/integration/test_command.py::test_main"
  ];

  pyproject = true;
  passthru.tests = nixosTests.pinnwand;

  meta = {
    description = "Python pastebin that tries to keep it simple";
    homepage = "https://github.com/supakeen/pinnwand";
    changelog = "https://github.com/supakeen/pinnwand/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    platforms = lib.platforms.linux;
    mainProgram = "pinnwand";
  };
})
