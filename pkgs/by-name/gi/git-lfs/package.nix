{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  buildGoModule,
  git,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "git-lfs";
  version = "3.7.1";

  src = fetchFromGitHub {
    owner = "git-lfs";
    repo = "git-lfs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N5ckTnyA3mueZre+rMhFZBiAFgEu4pmtzkiUidXnan8=";
  };

  nativeBuildInputs = [
    asciidoctor
    installShellFiles
  ];

  vendorHash = "sha256-SUnZ9uN43CAw/iHC8cPBm3nYD03d3Pg2pYS2PwjDCnE=";

  preBuild = ''
    CC= GOOS= GOARCH= go generate ./commands
  '';

  postBuild = ''
    make man
  '';

  nativeCheckInputs = [ git ];

  checkFlags = lib.optionals stdenv.hostPlatform.isDarwin (
    let
      # Fail in the sandbox with network-related errors.
      # Enabling __darwinAllowLocalNetworking is not enough.
      skippedTests = [
        "TestAPIBatch"
        "TestAPIBatchOnlyBasic"
        "TestAuthErrWithBody"
        "TestAuthErrWithoutBody"
        "TestCertFromSSLCAInfoConfig"
        "TestCertFromSSLCAInfoEnv"
        "TestCertFromSSLCAInfoEnvWithSchannelBackend"
        "TestCertFromSSLCAPathConfig"
        "TestCertFromSSLCAPathEnv"
        "TestClientRedirect"
        "TestClientRedirectReauthenticate"
        "TestDoAPIRequestWithAuth"
        "TestDoWithAuthApprove"
        "TestDoWithAuthNoRetry"
        "TestDoWithAuthReject"
        "TestFatalWithBody"
        "TestFatalWithoutBody"
        "TestHttp2"
        "TestHttpVersion"
        "TestWithNonFatal500WithBody"
        "TestWithNonFatal500WithoutBody"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ]
  );

  preCheck = ''
    unset subPackages
  '';

  postInstall = ''
    installManPage man/man*/*
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd git-lfs \
      --bash <($out/bin/git-lfs completion bash) \
      --fish <($out/bin/git-lfs completion fish) \
      --zsh <($out/bin/git-lfs completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/git-lfs/git-lfs/v${lib.versions.major finalAttrs.version}/config.Vendor=${finalAttrs.version}"
  ];

  proxyVendor = true;
  subPackages = [ "." ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Git extension for versioning large files";
    homepage = "https://git-lfs.github.com/";
    changelog = "https://github.com/git-lfs/git-lfs/raw/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      twey
      savtrip
    ];

    mainProgram = "git-lfs";
  };
})
