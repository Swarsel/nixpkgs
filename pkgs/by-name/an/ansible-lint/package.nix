{
  lib,
  ansible,
  fetchPypi,
  python3Packages,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ansible-lint";
  version = "25.8.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-Nd093RLYBjh2kVvy8GuaG4D9J6fLHKTOUcjOu4RpCSI=";
    pname = "ansible_lint";
  };

  postPatch = ''
    # it is fine if lint tools are missing
    substituteInPlace conftest.py \
      --replace-fail "sys.exit(1)" ""
  '';

  # tests can't be easily run without installing things from ansible-galaxy
  doCheck = false;

  nativeCheckInputs =
    with python3Packages;
    [
      flaky
      pytest-xdist
      pytestCheckHook
    ]
    ++ [
      writableTmpDirAsHomeHook
      ansible
    ];

  preCheck = ''
    # create a working ansible-lint executable
    export PATH=$PATH:$PWD/src/ansiblelint
    ln -rs src/ansiblelint/__main__.py src/ansiblelint/ansible-lint
    patchShebangs src/ansiblelint/__main__.py

    # create symlink like in the git repo so test_included_tasks does not fail
    ln -s ../roles examples/playbooks/roles
  '';

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    # https://github.com/ansible/ansible-lint/blob/master/.config/requirements.in
    ansible-core
    ansible-compat
    black
    filelock
    importlib-metadata
    jsonschema
    packaging
    pyyaml
    rich
    ruamel-yaml
    subprocess-tee
    wcmatch
    yamllint
  ];

  disabledTests = [
    # requires network
    "test_cli_auto_detect"
    "test_install_collection"
    "test_prerun_reqs_v1"
    "test_prerun_reqs_v2"
    "test_require_collection_wrong_version"
    # re-execs ansible-lint which does not works correct
    "test_custom_kinds"
    "test_run_inside_role_dir"
    "test_run_multiple_role_path_no_trailing_slash"
    "test_runner_exclude_globs"
    "test_discover_lintables_umlaut"
  ];

  makeWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [ ansible ]}" ];
  pyproject = true;
  pythonRelaxDeps = [ "ruamel.yaml" ];

  meta = {
    description = "Best practices checker for Ansible";
    homepage = "https://github.com/ansible/ansible-lint";
    changelog = "https://github.com/ansible/ansible-lint/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sengaya
      HarisDotParis
      robsliwi
    ];

    mainProgram = "ansible-lint";
  };
})
