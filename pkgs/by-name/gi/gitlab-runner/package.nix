{
  lib,
  stdenv,
  fetchFromGitLab,
  bash,
  buildGoModule,
  gitMinimal,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "gitlab-runner";
  version = "19.0.0";

  src = fetchFromGitLab {
    owner = "gitlab-org";
    repo = "gitlab-runner";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uScTzj4pSRtSFCMxoOR5KqipCbPknwnydPYG6xU5dOo=";
  };

  patches = [
    ./fix-shell-path.patch
    ./remove-bash-test.patch
  ];

  postPatch = ''
    patchShebangs --build helpers/docker/auth/testdata/docker-credential-bin.sh
  '';

  # For patchShebangs
  buildInputs = [ bash ];
  vendorHash = "sha256-QqqTkIgR9ca1dYQ32SG7C+SpEIA07Hlf8x3lVhZ5vRQ=";

  nativeCheckInputs = [
    gitMinimal
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    # Make the tests pass outside of GitLab CI
    export CI=0
  '';

  postInstall = ''
    install packaging/root/usr/share/gitlab-runner/clear-docker-cache $out/bin
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  # Many tests start servers which bind to ports
  __darwinAllowLocalNetworking = true;

  excludedPackages = [
    # Nested dependency Go module, used with go.mod replace directive
    #
    # https://gitlab.com/gitlab-org/gitlab-runner/-/commit/57ea9df5d8a8deb78c8d1972930bbeaa80d05e78
    "./helpers/runner_wrapper/api"
    # Helper scripts for upstream Make targets, not intended for downstream consumers
    "./scripts"
  ];

  ldflags =
    let
      ldflagsPackageVariablePrefix = "gitlab.com/gitlab-org/gitlab-runner/common";
    in
    [
      "-X ${ldflagsPackageVariablePrefix}.NAME=gitlab-runner"
      "-X ${ldflagsPackageVariablePrefix}.VERSION=${finalAttrs.version}"
      "-X ${ldflagsPackageVariablePrefix}.REVISION=v${finalAttrs.version}"
    ];

  prePatch = ''
    # Remove some tests that can't work during a nix build

    # Needs the build directory to be a git repo
    substituteInPlace commands/helpers/file_archiver_test.go \
      --replace-fail "func TestCacheArchiverAddingUntrackedFiles" "func OFF_TestCacheArchiverAddingUntrackedFiles" \
      --replace-fail "func TestCacheArchiverAddingUntrackedUnicodeFiles" "func OFF_TestCacheArchiverAddingUntrackedUnicodeFiles"

    # Needs `make development_setup` (git repo at tmp/gitlab-test/)
    rm common/build_settings_test.go
    rm common/build_test.go
    rm executors/custom/custom_test.go

    # Timing-dependent test causes spurious failures on Hydra.
    # Might be fixed upstream in this MR: https://gitlab.com/gitlab-org/gitlab-runner/-/merge_requests/6623
    # Try dropping it on next major version bump
    rm executors/kubernetes/internal/watchers/pod_test.go
  ''
  + lib.optionalString (!stdenv.buildPlatform.isx86_64) ''
    # Kubernetes tests actually work fine inside the network sandbox (they don't
    # expect real Kubernetes), but they fail on aarch64-linux because their
    # mocks expect x86_64
    rm executors/kubernetes/kubernetes_test.go
    rm executors/kubernetes/overwrites_test.go
  ''
  + lib.optionalString stdenv.buildPlatform.isDarwin ''
    # Darwin's sandbox blocks sendfile(2) during local HTTP PUT uploads
    substituteInPlace commands/helpers/cache_archiver_test.go \
      --replace-fail "func TestUploadExistingArchiveIfNeeded" "func OFF_TestUploadExistingArchiveIfNeeded"

    # Invalid bind arguments break Unix socket tests.
    substituteInPlace commands/wrapper_test.go \
      --replace-fail "func TestRunnerWrapperCommand_createListener" "func OFF_TestRunnerWrapperCommand_createListener"

    # No keychain access during build breaks X.509 certificate tests
    substituteInPlace helpers/certificate/x509_test.go \
      --replace-fail "func TestCertificate" "func OFF_TestCertificate"
    substituteInPlace network/client_test.go \
      --replace-fail "func TestClientInvalidSSL" "func OFF_TestClientInvalidSSL"
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "GitLab Runner the continuous integration executor of GitLab";
    homepage = "https://docs.gitlab.com/runner";
    changelog = "https://gitlab.com/gitlab-org/gitlab-runner/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zimbatm ];
    mainProgram = "gitlab-runner";
    teams = [ lib.teams.gitlab ];
  };
})
