{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "jiratui";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "whyisdifficult";
    repo = "jiratui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b5bSMPnqHqpeFDl501gSun7G38OlhV/IMNMYXQT+j/4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.2,<0.10.0" "uv_build>=0.9.2"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  build-system = with python3Packages; [
    uv-build
  ];

  dependencies =
    with python3Packages;
    [
      click
      gitpython
      httpx
      pyaml
      pydantic-settings
      python-dateutil
      python-json-logger
      python-magic
      textual
      textual-image
      xdg-base-dirs
    ]
    ++ textual.optional-dependencies.syntax;

  pyproject = true;

  pythonImportsCheck = [
    "jiratui"
  ];

  pythonRelaxDeps = [
    "click"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "A Textual User Interface for interacting with Atlassian Jira from your shell";
    homepage = "https://github.com/whyisdifficult/jiratui";
    changelog = "https://github.com/whyisdifficult/jiratui/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
    mainProgram = "jiratui";
  };
})
