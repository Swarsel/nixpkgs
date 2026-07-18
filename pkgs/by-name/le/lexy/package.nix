{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "lexy";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "antoniorodr";
    repo = "lexy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OT+RaoIC+CxHHFdi3Hp405B/tWCTsPPrK8aDowKOUFc=";
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    beautifulsoup4
    click
    requests
    typer
    tomlkit
  ];

  optional-dependencies = with python3Packages; {
    docs = [
      mkdocs
      mkdocs-awesome-nav
      mkdocs-material
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "lexy"
  ];

  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight CLI tool that fetches programming tutorials from \"Learn X in Y Minutes\" directly into your terminal";
    homepage = "https://github.com/antoniorodr/lexy.git";
    changelog = "https://github.com/antoniorodr/lexy/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ puiyq ];
    mainProgram = "lexy";
  };
})
