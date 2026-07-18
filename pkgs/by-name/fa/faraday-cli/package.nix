{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "faraday-cli";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "infobyte";
    repo = "faraday-cli";
    tag = finalAttrs.version;
    hash = "sha256-OQhwohRtBLwVWEJhyGBs/ktOL5SH+jM9A9/HnyheJYE=";
  };

  # Tests requires credentials
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    arrow
    click
    cmd2
    colorama
    faraday-plugins
    jsonschema
    log-symbols
    luddite
    packaging
    pyyaml
    py-sneakers
    simple-rest-client
    spinners
    tabulate
    termcolor
    validators
  ];

  pyproject = true;
  pythonImportsCheck = [ "faraday_cli" ];

  pythonRelaxDeps = [
    "cmd2"
    "httpx"
    "validators"
  ];

  meta = {
    description = "Command Line Interface for Faraday";
    homepage = "https://github.com/infobyte/faraday-cli";
    changelog = "https://github.com/infobyte/faraday-cli/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "faraday-cli";
  };
})
