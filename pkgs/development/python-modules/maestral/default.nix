{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  dbus-python,
  desktop-notifier,
  dropbox,
  fasteners,
  gitUpdater,
  importlib-metadata,
  keyring,
  keyrings-alt,
  makePythonPath,
  nixosTests,
  packaging,
  pathspec,
  pyro5,
  pytestCheckHook,
  python,
  requests,
  rich,
  rubicon-objc,
  setuptools,
  survey,
  typing-extensions,
  watchdog,
  xattr,
}:

buildPythonPackage (finalAttrs: {
  pname = "maestral";
  version = "1.9.6";

  src = fetchFromGitHub {
    owner = "SamSchott";
    repo = "maestral";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mYFiQL4FumJWP2y1u5tIo1CZL027J8/EIYqJQde7G/c=";
  };

  # ModuleNotFoundError: No module named '_watchdog_fsevents'
  doCheck = !(stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64);
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  build-system = [ setuptools ];

  dependencies = [
    click
    desktop-notifier
    dbus-python
    dropbox
    fasteners
    keyring
    keyrings-alt
    packaging
    pathspec
    pyro5
    requests
    rich
    setuptools
    survey
    typing-extensions
    watchdog
    xattr
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ rubicon-objc ];

  disabledTests = [
    # We don't want to benchmark
    "test_performance"
    # Requires systemd
    "test_autostart"
    # Requires network access
    "test_check_for_updates"
    # Tries to look at /usr
    "test_filestatus"
    "test_path_exists_case_insensitive"
    "test_cased_path_candidates"
    # AssertionError
    "test_locking_multiprocess"
    # OSError: [Errno 95] Operation not supported
    "test_move_preserves_xattrs"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # maetral daemon does not start but worked in real environment
    "test_catching_non_ignored_events"
    "test_connection"
    "test_event_handler"
    "test_fs_ignore_tree_creation"
    "test_lifecycle"
    "test_notify_level"
    "test_notify_snooze"
    "test_receiving_events"
    "test_remote_exceptions"
    "test_start_already_running"
    "test_stop"
  ];

  makeWrapperArgs = [
    # Add the installed directories to the python path so the daemon can find them
    "--prefix"
    "PYTHONPATH"
    ":"
    (makePythonPath finalAttrs.finalPackage.dependencies)
    "--prefix"
    "PYTHONPATH"
    ":"
    "$out/${python.sitePackages}"
  ];

  pyproject = true;
  pythonImportsCheck = [ "maestral" ];

  passthru = {
    tests.maestral = nixosTests.maestral;

    updateScript = gitUpdater {
      ignoredVersions = "dev";
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Open-source Dropbox client for macOS and Linux";
    homepage = "https://maestral.app";
    changelog = "https://github.com/samschott/maestral/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      natsukium
      peterhoeg
      sfrijters
    ];

    mainProgram = "maestral";
  };
})
