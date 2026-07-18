{
  lib,
  fetchFromGitHub,
  nb-cli,
  python3,
  testers,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "nb-cli";
  version = "1.7.4";

  src = fetchFromGitHub {
    owner = "nonebot";
    repo = "nb-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Vo+MmbaC+i/FZfrZywb2vgNQotafLyXpdBo6pDlZeaE=";
  };

  # no test
  doCheck = false;

  build-system = with python3.pkgs; [
    babel
    pdm-backend
  ];

  dependencies = with python3.pkgs; [
    anyio
    cashews
    click
    cookiecutter
    httpx
    importlib-metadata
    jinja2
    noneprompt
    nonestorage
    packaging
    pydantic
    pyfiglet
    textual
    tomlkit
    typing-extensions
    virtualenv
    watchfiles
    wcwidth
  ];

  pyproject = true;

  pythonImportsCheck = [
    "nb_cli"
    "nb_cli.cli"
    "nb_cli.compat"
    "nb_cli.config"
    "nb_cli.handlers"
    "nb_cli.i18n"
    "nb_cli.log"
  ];

  # too strict
  pythonRelaxDeps = true;
  pythonRemoveDeps = [ "pip" ];

  passthru.tests = {
    version = testers.testVersion { package = nb-cli; };
  };

  meta = {
    description = "CLI for nonebot2";
    homepage = "https://cli.nonebot.dev";
    changelog = "https://github.com/nonebot/nb-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "nb";
  };
})
