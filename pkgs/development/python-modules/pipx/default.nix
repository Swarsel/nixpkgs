{
  lib,
  fetchFromGitHub,
  argcomplete,
  buildPythonPackage,
  colorama,
  git,
  hatch-vcs,
  hatchling,
  installShellFiles,
  packaging,
  platformdirs,
  pypiserver,
  pytest-cov-stub,
  pytest-mock,
  pytest-subprocess,
  pytest-xdist,
  pytestCheckHook,
  tomli,
  userpath,
  uv,
  watchdog,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pipx";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "pypa";
    repo = "pipx";
    tag = finalAttrs.version;
    hash = "sha256-4qSCyaYHam9y04qTgEUvbo/XiY9WNqX2fKZJOAVE2EM=";
  };

  nativeBuildInputs = [
    installShellFiles
    argcomplete
  ];

  nativeCheckInputs = [
    pytestCheckHook
    git
    writableTmpDirAsHomeHook
    pypiserver
    pytest-cov-stub
    pytest-mock
    pytest-subprocess
    pytest-xdist
    watchdog
  ];

  postInstall = ''
    installShellCompletion --cmd pipx \
      --bash <(register-python-argcomplete pipx --shell bash) \
      --zsh <(register-python-argcomplete pipx --shell zsh) \
      --fish <(register-python-argcomplete pipx --shell fish)
  '';

  __structuredAttrs = true;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    argcomplete
    colorama
    packaging
    platformdirs
    tomli
    userpath
  ]
  ++ finalAttrs.passthru.optional-dependencies.uv;

  disabledTests = [
    # disable tests, which require internet connection
    "install"
    "inject"
    "ensure_null_pythonpath"
    "missing_interpreter"
    "cache"
    "internet"
    "run"
    "runpip"
    "upgrade"
    "suffix"
    "legacy_venv"
    "determination"
    "json"
    "test_auto_update_shared_libs"
    "test_cli"
    "test_cli_global"
    "test_fetch_missing_python"
    "test_list_does_not_trigger_maintenance"
    "test_list_pinned_packages"
    "test_list_short"
    "test_list_standalone_interpreter"
    "test_list_unused_standalone_interpreters"
    "test_list_used_standalone_interpreters"
    "test_pin"
    "test_skip_maintenance"
    "test_unpin"
    "test_unpin_warning"
    "test_shared_libs_excludes_setuptools"
  ];

  optional-dependencies = {
    uv = [
      uv
    ];
  };

  pyproject = true;

  pytestFlags = [
    # start local pypi server and use in tests
    "--net-pypiserver"
  ];

  pythonImportsCheck = [ "pipx" ];

  meta = {
    description = "Install and run Python applications in isolated environments";
    homepage = "https://github.com/pypa/pipx";
    changelog = "https://github.com/pypa/pipx/blob/main/docs/changelog.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yshym ];
    mainProgram = "pipx";
  };
})
