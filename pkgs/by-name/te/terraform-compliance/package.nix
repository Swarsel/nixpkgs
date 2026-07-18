{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "terraform-compliance";
  version = "1.15.1";

  src = fetchFromGitHub {
    owner = "terraform-compliance";
    repo = "cli";
    tag = finalAttrs.version;
    hash = "sha256-saDpAek0QJy0YxGUPw8A5hLa0fmH5uX0FezcfEKkikI=";
  };

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    diskcache
    emoji
    filetype
    gitpython
    ipython
    junit-xml
    lxml
    mock
    netaddr
    radish-bdd
    semver
    orjson
  ];

  disabledTests = [
    "test_which_success"
    "test_readable_plan_file_is_not_json"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "terraform_compliance"
  ];

  pythonRelaxDeps = [
    "radish-bdd"
    "IPython"
  ];

  meta = {
    description = "BDD test framework for terraform";
    homepage = "https://github.com/terraform-compliance/cli";
    changelog = "https://github.com/terraform-compliance/cli/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kalbasit
      kashw2
    ];

    mainProgram = "terraform-compliance";
  };
})
