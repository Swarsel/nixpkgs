{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  git,
  installShellFiles,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "git-spice";
  version = "0.31.0";

  src = fetchFromGitHub {
    owner = "abhinav";
    repo = "git-spice";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3VHT9/oCQaySWPAfnZYRxSsKCz8S8As685V3wvpqip8=";
  };

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ git ];
  vendorHash = "sha256-xcU0B+ju1f/JfNVKpXkIy5SO9rd3O9Nl0FizW3kVgI0=";
  nativeCheckInputs = [ git ];

  preCheck = lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) ''
    # timeout
    rm testdata/script/branch_submit_remote_prompt.txt
    rm testdata/script/branch_submit_multiple_pr_templates.txt
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd gs \
      --bash <($out/bin/gs shell completion bash) \
      --zsh <($out/bin/gs shell completion zsh) \
      --fish <($out/bin/gs shell completion fish)
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-X=main._version=${finalAttrs.version}"
  ];

  subPackages = [ "." ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Manage stacked Git branches";
    homepage = "https://abhinav.github.io/git-spice/";
    changelog = "https://github.com/abhinav/git-spice/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.vinnymeller ];
    mainProgram = "gs";
  };
})
