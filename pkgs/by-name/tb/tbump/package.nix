{
  lib,
  fetchFromGitHub,
  gitMinimal,
  gitSetupHook,
  python3Packages,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tbump";
  version = "6.11.0";

  src = fetchFromGitHub {
    owner = "your-tools";
    repo = "tbump";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+H4C4q+/QlYFgz9hvDZhKtREpa8yN1xLx99odSI3WlY=";
  };

  nativeCheckInputs = with python3Packages; [
    gitMinimal
    gitSetupHook
    pytest-mock
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    docopt
    schema
    packaging
    poetry-core
    tomlkit
    cli-ui
  ];

  pyproject = true;
  pythonRelaxDeps = [ "tomlkit" ];

  meta = {
    description = "Bump software releases";
    homepage = "https://github.com/your-tools/tbump";
    changelog = "https://github.com/your-tools/tbump/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ slashformotion ];
    mainProgram = "tbump";
  };
})
