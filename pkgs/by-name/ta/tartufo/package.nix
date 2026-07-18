{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "tartufo";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "godaddy";
    repo = "tartufo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GWxDGsoWVKjg/2zTPx+xsMmrBp6yAC5pq5/AALmY7No=";
  };

  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    cached-property
    click
    colorama
    gitpython
    pygit2
    tomlkit
  ];

  pyproject = true;
  pythonImportsCheck = [ "tartufo" ];

  pythonRelaxDeps = [
    "cached-property"
    "tomlkit"
  ];

  meta = {
    description = "Tool to search through git repositories for high entropy strings and secrets";
    homepage = "https://github.com/godaddy/tartufo";
    changelog = "https://github.com/godaddy/tartufo/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "tartufo";
  };
})
