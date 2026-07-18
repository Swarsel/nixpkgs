{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "notation";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "notaryproject";
    repo = "notation";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l9A5AwKJ/atN92Oral6PRH2nCbMJ+/ST9weXYRZXWms=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-WFcy7to3bV3V3bBto5F175PEIxrG9Tj7MuLeBXdSvaM=";

  postInstall =
    let
      exe =
        if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
          "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}"
        else
          lib.getExe buildPackages.notation;
    in
    ''
      installShellCompletion --cmd ${finalAttrs.meta.mainProgram} \
        --bash <(${exe} completion bash) \
        --fish <(${exe} completion fish) \
        --zsh <(${exe} completion zsh)
    '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  # tests bind to localhost
  __darwinAllowLocalNetworking = true;

  # This is a Go sub-module and cannot be built directly (e2e tests).
  excludedPackages = [
    "./test/e2e"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/notaryproject/notation/internal/version.Version=${finalAttrs.version}"
    "-X github.com/notaryproject/notation/internal/version.BuildMetadata="
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "CLI tool to sign and verify OCI artifacts and container images";
    homepage = "https://notaryproject.dev/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      jk
      vdemeester
    ];

    mainProgram = "notation";
  };
})
