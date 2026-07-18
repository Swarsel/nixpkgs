{
  lib,
  attrs,
  buildPythonPackage,
  cattrs,
  click,
  click-option-group,
  fetchPypi,
  hatch-vcs,
  hatchling,
  hypothesis,
  jinja2,
  pydantic,
  pytest-cov-stub,
  pytestCheckHook,
  python-dotenv,
  pythonAtLeast,
  rich-click,
  sybil,
}:
buildPythonPackage rec {
  pname = "typed-settings";
  version = "25.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-hl61LDGE9GdwVkWh5Y251xngi515V0SKKtjLvCLtIaY=";
    pname = "typed_settings";
  };

  nativeBuildInputs = [ hatch-vcs ];

  nativeCheckInputs = [
    hypothesis
    pytest-cov-stub
    pytestCheckHook
    python-dotenv
    rich-click
    sybil
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ hatchling ];

  disabledTestPaths = [
    # 1Password CLI is not available
    "tests/test_onepassword.py"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # All the CLI help messages begin with python3.14 instead of python3
    "tests/test_cli_argparse.py"
  ];

  disabledTests = [
    # 1Password CLI is not available
    "TestOnePasswordLoader"
    "test_handle_op"
  ];

  enabledTestPaths = [ "tests" ];

  optional-dependencies = {
    all = [
      attrs
      cattrs
      click
      click-option-group
      jinja2
      pydantic
    ];

    attrs = [ attrs ];
    cattrs = [ cattrs ];
    click = [ click ];
    jinja = [ jinja2 ];

    option-groups = [
      click
      click-option-group
    ];

    pydantic = [ pydantic ];
  };

  pyproject = true;
  pythonImportsCheck = [ "typed_settings" ];

  meta = {
    description = "Typed settings based on attrs classes";
    homepage = "https://gitlab.com/sscherfke/typed-settings";
    changelog = "https://gitlab.com/sscherfke/typed-settings/-/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
