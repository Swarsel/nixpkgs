{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  git,
  git-town,
  installShellFiles,
  makeWrapper,
  testers,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "git-town";
  version = "23.0.3";

  src = fetchFromGitHub {
    owner = "git-town";
    repo = "git-town";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vw8S1Y9yXERL9Ddt70Elz0pZZHAuC+C9231Y8o1mb9k=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  buildInputs = [ git ];
  vendorHash = null;

  nativeCheckInputs = [
    git
    writableTmpDirAsHomeHook
  ];

  checkFlags =
    let
      # Disable tests requiring local operations
      skippedTests = [
        "TestMockingRunner/MockCommand"
        "TestMockingRunner/MockCommitMessage"
        "TestMockingRunner/QueryWith"
        "TestTestCommands/CreateChildFeatureBranch"
        "TestTestCommands/CreateChildBranch"
        "TestTestCommands/CreateLocalBranchUsingGitTown"
        "TestFrontendRunner_RetryOnIndexLock" # Timing issues.

      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  preCheck = ''
    # this runs tests requiring local operations
    rm main_test.go
  '';

  postInstall =
    lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd git-town \
        --bash <($out/bin/git-town completions bash) \
        --fish <($out/bin/git-town completions fish) \
        --zsh <($out/bin/git-town completions zsh)
    ''
    + ''
      wrapProgram $out/bin/git-town --prefix PATH : ${lib.makeBinPath [ git ]}
    '';

  ldflags =
    let
      modulePath = "github.com/git-town/git-town/v${lib.versions.major finalAttrs.version}";
    in
    [
      "-s"
      "-w"
      "-X ${modulePath}/src/cmd.version=v${finalAttrs.version}"
      "-X ${modulePath}/src/cmd.buildDate=nix"
    ];

  passthru.tests.version = testers.testVersion {
    inherit (finalAttrs) version;
    command = "git-town --version";
    package = git-town;
  };

  meta = {
    description = "Generic, high-level git support for git-flow workflows";
    homepage = "https://www.git-town.com/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      allonsy
      gabyx
    ];

    mainProgram = "git-town";
  };
})
