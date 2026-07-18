{
  lib,
  fetchFromGitHub,
  jrnl,
  python3,
  testers,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "jrnl";
  version = "4.2";

  src = fetchFromGitHub {
    owner = "jrnl-org";
    repo = "jrnl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-x0JoYJzD6RnuHbRsQMgrhHsNW6nVEVeoDjtPop2eg+w=";
  };

  postPatch = ''
    # Support pytest_bdd 7.1.2 and later, https://github.com/jrnl-org/jrnl/pull/1878
    substituteInPlace tests/lib/when_steps.py \
      --replace-fail "from pytest_bdd.steps import inject_fixture" "from pytest_bdd.compat import inject_fixture"
  '';

  nativeCheckInputs = with python3.pkgs; [
    pytest-bdd
    pytest-xdist
    (pytestCheckHook.override { pytest = pytest_7; })
    toml
  ];

  preCheck = ''
    export HOME=$(mktemp -d);
  '';

  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    asteval
    colorama
    cryptography
    keyring
    parsedatetime
    python-dateutil
    pytz
    pyxdg
    pyyaml
    tzlocal
    ruamel-yaml
    rich
  ];

  disabledTests = [
    "test_override_configured_linewrap_with_a_value_of_23"
  ];

  pyproject = true;
  pythonImportsCheck = [ "jrnl" ];
  pythonRelaxDeps = [ "rich" ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = jrnl;
  };

  meta = {
    description = "Command line journal application that stores your journal in a plain text file";
    homepage = "https://jrnl.sh/";
    changelog = "https://github.com/jrnl-org/jrnl/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      zalakain
    ];

    mainProgram = "jrnl";
  };
})
