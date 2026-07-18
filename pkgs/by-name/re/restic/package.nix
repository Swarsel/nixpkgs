{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  makeBinaryWrapper,
  nixosTests,
  openssh,
  python3,
  rclone,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "restic";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "restic";
    repo = "restic";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lj2+SZFvZl/WcC4aV7yZMEYVOyDNMFeHJbUWS53usqg=";
  };

  patches = [
    # The TestRestoreWithPermissionFailure test fails in Nix’s build sandbox
    ./0001-Skip-testing-restore-with-permission-failure.patch
  ];

  postPatch = ''
    rm cmd/restic/cmd_mount_integration_test.go
  '';

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ];

  vendorHash = "sha256-6r97M0XHuddbpSZ9yTtfIPUDkHkHP2PIDLWQTf/294E=";
  nativeCheckInputs = [ python3 ];

  postInstall = ''
    wrapProgram $out/bin/restic \
      --prefix PATH : "${
        lib.makeBinPath [
          openssh
          rclone
        ]
      }"
  ''
  + lib.optionalString (stdenv.hostPlatform == stdenv.buildPlatform) ''
    $out/bin/restic generate \
      --bash-completion restic.bash \
      --fish-completion restic.fish \
      --zsh-completion restic.zsh \
      --man .
    installShellCompletion restic.{bash,fish,zsh}
    installManPage *.1
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  subPackages = [ "cmd/restic" ];
  versionCheckProgramArg = "version";

  passthru.tests = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    restic = nixosTests.restic;
  };

  meta = {
    description = "Backup program that is fast, efficient and secure";
    homepage = "https://restic.net";
    changelog = "https://github.com/restic/restic/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      mbrgm
      djds
      dotlambda
      ryan4yin
    ];

    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "restic";
  };
})
