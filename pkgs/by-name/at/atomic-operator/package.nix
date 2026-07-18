{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "atomic-operator";
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "swimlane";
    repo = "atomic-operator";
    tag = finalAttrs.version;
    hash = "sha256-DyNqu3vndyLkmfybCfTbgxk3t/ALg7IAkAMg4kBkH7Q=";
  };

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    attrs
    certifi
    chardet
    charset-normalizer
    fire
    idna
    paramiko
    pick
    pypsrp
    pyyaml
    requests
    urllib3
  ];

  disabledTests = [
    # Tests require network access
    "test_download_of_atomic_red_team_repo"
    "test_setting_input_arguments"
    "test_config_parser"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "atomic_operator"
  ];

  pythonRelaxDeps = [
    "charset_normalizer"
    "urllib3"
  ];

  meta = {
    description = "Tool to execute Atomic Red Team tests (Atomics)";
    homepage = "https://www.atomic-operator.com/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "atomic-operator";
  };
})
