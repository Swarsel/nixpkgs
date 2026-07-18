{
  lib,
  fetchFromGitHub,
  dbus,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  samba,
  stdenvNoCC,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "termscp";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "veeso";
    repo = "termscp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Alp0/f0OqLD7UeJwDhr2OIuk1TPXLQPAVUsZOQzo5jI=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    openssl
    samba
  ];

  cargoHash = "sha256-7xD+86v0ITBKF8js4UKwoTJFHa20wt6PDqkazShBtvc=";
  # Needed to get openssl-sys to use pkg-config.
  env.OPENSSL_NO_VENDOR = 1;

  checkFlags = [
    # requires networking
    "--skip=cli::remote::test::test_should_make_remote_args_from_one_bookmark_and_one_remote_with_local_dir"
    "--skip=cli::remote::test::test_should_make_remote_args_from_two_bookmarks_and_local_dir"
    "--skip=cli::remote::test::test_should_make_remote_args_from_two_remotes_and_local_dir"
    "--skip=system::auto_update::test::test_should_check_whether_github_api_is_reachable"
    "--skip=system::environment::tests::test_system_environment_get_config_dir_err"
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [
    "--skip=system::watcher::test::should_poll_file_removed"
    "--skip=system::watcher::test::should_poll_file_update"
    "--skip=system::watcher::test::should_poll_nothing"
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  checkFeatures = [ "isolated-tests" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Feature rich terminal UI file transfer and explorer with support for SCP/SFTP/FTP/S3/SMB";
    homepage = "https://github.com/veeso/termscp";
    changelog = "https://github.com/veeso/termscp/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fab
      gepbird
    ];

    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "termscp";
  };
})
