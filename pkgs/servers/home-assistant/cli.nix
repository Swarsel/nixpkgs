{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "homeassistant-cli";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "home-assistant-ecosystem";
    repo = "home-assistant-cli";
    tag = finalAttrs.version;
    hash = "sha256-LF6JXELAP3Mvta3RuDUs4UiQ7ptNFh0vZmPh3ICJFRY=";
  };

  nativeBuildInputs = [ installShellFiles ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    requests-mock
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd hass-cli \
      --bash <(_HASS_CLI_COMPLETE=bash_source $out/bin/hass-cli) \
      --fish <(_HASS_CLI_COMPLETE=fish_source $out/bin/hass-cli) \
      --zsh <(_HASS_CLI_COMPLETE=zsh_source $out/bin/hass-cli)
  '';

  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    aiohttp
    click
    click-log
    dateparser
    jinja2
    jsonpath-ng
    netdisco
    regex
    requests
    ruamel-yaml
    tabulate
  ];

  pyproject = true;
  pythonImportsCheck = [ "homeassistant_cli" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Command-line tool for Home Assistant";
    homepage = "https://github.com/home-assistant-ecosystem/home-assistant-cli";
    changelog = "https://github.com/home-assistant-ecosystem/home-assistant-cli/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    mainProgram = "hass-cli";
    teams = [ lib.teams.home-assistant ];
  };
})
