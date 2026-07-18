{
  lib,
  fetchFromGitHub,
  nixosTests,
  pkgs,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "steck";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "supakeen";
    repo = "steck";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5Spops8ERQ7TgFYH7n+c4hKdIQfjjujKaGhmhfAszgQ=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    pkgs.git
    appdirs
    click
    python-magic
    requests
    termcolor
    toml
  ];

  pyproject = true;
  pythonRelaxDeps = [ "termcolor" ];
  passthru.tests = nixosTests.pinnwand;

  meta = {
    description = "Client for pinnwand pastebin";
    homepage = "https://github.com/supakeen/steck";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "steck";
  };
})
