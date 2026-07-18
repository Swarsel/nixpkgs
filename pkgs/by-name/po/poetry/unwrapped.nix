{
  lib,
  stdenv,
  fetchFromGitHub,
  build,
  buildPythonPackage,
  cachecontrol,
  cleo,
  deepdiff,
  dulwich,
  fastjsonschema,
  findpython,
  httpretty,
  installShellFiles,
  installer,
  keyring,
  packaging,
  pbs-installer,
  pkginfo,
  platformdirs,
  poetry-core,
  pyproject-hooks,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  requests,
  requests-toolbelt,
  responses,
  shellingham,
  tomlkit,
  trove-classifiers,
  virtualenv,
  xattr,
}:

buildPythonPackage rec {
  pname = "poetry";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "python-poetry";
    repo = "poetry";
    tag = version;
    hash = "sha256-Mb1etVmBm542q7FrcMU6pzXdMUDQSpI8DFg/gbOiG4U=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  nativeCheckInputs = [
    deepdiff
    pytestCheckHook
    httpretty
    pytest-mock
    pytest-xdist
    responses
  ];

  preCheck = (
    ''
      export HOME=$TMPDIR
    ''
    + lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) ''
      # https://github.com/python/cpython/issues/74570#issuecomment-1093748531
      export no_proxy='*';
    ''
  );

  postCheck = lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) ''
    unset no_proxy
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd poetry \
      --bash <($out/bin/poetry completions bash) \
      --fish <($out/bin/poetry completions fish) \
      --zsh <($out/bin/poetry completions zsh)
  '';

  build-system = [
    poetry-core
  ];

  dependencies = [
    build
    cachecontrol
    cleo
    dulwich
    fastjsonschema
    findpython
    installer
    keyring
    packaging
    pbs-installer
    pkginfo
    platformdirs
    poetry-core
    pyproject-hooks
    requests
    requests-toolbelt
    shellingham
    tomlkit
    trove-classifiers
    virtualenv
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin) [
    xattr
  ]
  ++ cachecontrol.optional-dependencies.filecache
  ++ pbs-installer.optional-dependencies.download
  ++ pbs-installer.optional-dependencies.install;

  disabledTestMarks = [
    "network"
  ];

  disabledTests = [
    "test_builder_should_execute_build_scripts"
    "test_env_system_packages_are_relative_to_lib"
    "test_install_warning_corrupt_root"
    "test_no_additional_output_in_verbose_mode"
    "test_project_plugins_are_installed_in_project_folder"
    "test_application_command_not_found_messages"
    # PermissionError: [Errno 13] Permission denied: '/build/pytest-of-nixbld/pytest-0/popen-gw3/test_find_poetry_managed_pytho1/.local/share/pypoetry/python/pypy@3.10.8/bin/python'
    "test_list_poetry_managed"
    "test_list_poetry_managed"
    "test_find_all_with_poetry_managed"
    "test_find_poetry_managed_pythons"
    # Flaky
    "test_threading_property_types"
    "test_threading_single_thread_safe"
    "test_threading_property_caching"
    "test_threading_atomic_cached_property_different_instances"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Sandbox violation:
    # PermissionError: [Errno 1] Operation not permitted: '/Library/Frameworks/Python.framework/Versions'
    "test_find_all"
  ];

  # Unset ambient PYTHONPATH in the wrapper, so Poetry only ever runs with its own,
  # isolated set of dependencies. This works because the correct PYTHONPATH is set
  # in the Python script, which runs after the wrapper.
  makeWrapperArgs = [ "--unset PYTHONPATH" ];
  pyproject = true;

  # Allow for package to use pep420's native namespaces
  pythonNamespaces = [
    "poetry"
  ];

  pythonRelaxDeps = [ "installer" ];

  meta = {
    description = "Python dependency management and packaging made easy";
    homepage = "https://python-poetry.org/";
    changelog = "https://github.com/python-poetry/poetry/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jakewaksbaum
      dotlambda
    ];

    mainProgram = "poetry";
  };
}
