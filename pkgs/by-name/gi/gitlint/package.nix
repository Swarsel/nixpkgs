{
  lib,
  fetchFromGitHub,
  gitMinimal,
  nix-update-script,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gitlint";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "jorisroovers";
    repo = "gitlint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4SGkkC4LjZXTDXwK6jMOIKXR1qX76CasOwSqv8XUrjs=";
  };

  nativeCheckInputs = [
    gitMinimal
    python3Packages.pytestCheckHook
    versionCheckHook
  ];

  build-system = with python3Packages; [
    hatch-vcs
    hatchling
  ];

  dependencies = with python3Packages; [
    arrow
    click
    sh
  ];

  pyproject = true;

  pythonImportsCheck = [
    "gitlint"
  ];

  # Upstream split the project into gitlint and gitlint-core to
  # simplify the dependency handling
  sourceRoot = "${finalAttrs.src.name}/gitlint-core";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Linting for your git commit messages";
    homepage = "https://jorisroovers.com/gitlint/";
    changelog = "https://github.com/jorisroovers/gitlint/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ethancedwards8
      fab
      matthiasbeyer
    ];

    mainProgram = "gitlint";
  };
})
