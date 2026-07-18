{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  less,
  makeWrapper,
  stackit-cli,
  testers,
  xdg-utils,
}:

buildGoModule (finalAttrs: {
  pname = "stackit-cli";
  version = "0.66.0";

  src = fetchFromGitHub {
    owner = "stackitcloud";
    repo = "stackit-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xGjp+3yqQS4n4I8xgDZb0WzS4mDQwa9tvOADxy1aRPE=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  vendorHash = "sha256-ALBq9urUqonQqkLevsHNghIbnBz7LNb+7987Gg+eRVE=";
  env.CGO_ENABLED = 0;
  nativeCheckInputs = [ less ];

  postInstall = ''
    mv $out/bin/{stackit-cli,stackit} # rename the binary

    installShellCompletion --cmd stackit \
      --bash <($out/bin/stackit completion bash) \
      --zsh  <($out/bin/stackit completion zsh)  \
      --fish <($out/bin/stackit completion fish)
    # Ensure that all 3 completion scripts exist AND have content (should be kept for regression testing)
    [ $(find $out/share -not -empty -type f | wc -l) -eq 3 ]
  '';

  postFixup = ''
    wrapProgram $out/bin/stackit \
      --suffix PATH : ${
        lib.makeBinPath [
          less
          xdg-utils
        ]
      }
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  passthru.tests = {
    version = testers.testVersion {
      command = "stackit --version";
      package = stackit-cli;
    };
  };

  meta = {
    description = "CLI to manage STACKIT cloud services";
    homepage = "https://github.com/stackitcloud/stackit-cli";
    changelog = "https://github.com/stackitcloud/stackit-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ DerRockWolf ];
    mainProgram = "stackit";
  };
})
