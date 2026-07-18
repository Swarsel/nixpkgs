{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  pcsclite,
  pkg-config,
  testers,
  pivKeySupport ? true,
  pkcs11Support ? true,
}:

buildGoModule (finalAttrs: {
  pname = "cosign";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "sigstore";
    repo = "cosign";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DOsGLU6W0JrUGpthILTZfKv3fC45SlIXkvt+idUn5Tc=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = lib.optional (stdenv.hostPlatform.isLinux && pivKeySupport) (lib.getDev pcsclite);
  vendorHash = "sha256-AeVvp+6iKiTZ4dWy5kjAS2njI3IU+ANgTdUxOFcihSg=";

  checkFlags =
    let
      # Skip tests that require network access
      skippedTests = [
        "TestLoadCertsKeylessVerification/default_fulcio"
        "TestGetCTLogPubKeys"
        "TestGetRekorPubKeys"
        "TestVerifyEmbeddedSCT"
        "TestValidateAndUnpackCertWithSCT"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  preCheck = ''
    # test all paths
    unset subPackages
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd cosign \
      --bash <($out/bin/cosign completion bash) \
      --fish <($out/bin/cosign completion fish) \
      --zsh <($out/bin/cosign completion zsh)
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X sigs.k8s.io/release-utils/version.gitVersion=v${finalAttrs.version}"
    "-X sigs.k8s.io/release-utils/version.gitTreeState=clean"
  ];

  subPackages = [
    "cmd/cosign"
  ];

  tags =
    [ ] ++ lib.optionals pivKeySupport [ "pivkey" ] ++ lib.optionals pkcs11Support [ "pkcs11key" ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "cosign version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Container Signing CLI with support for ephemeral keys and Sigstore signing";
    homepage = "https://github.com/sigstore/cosign";
    changelog = "https://github.com/sigstore/cosign/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      lesuisse
      jk
      developer-guy
    ];

    mainProgram = "cosign";
  };
})
