{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  writableTmpDirAsHomeHook,
}:
buildGoModule (finalAttrs: {
  pname = "nvs";
  version = "1.14.1";

  src = fetchFromGitHub {
    owner = "y3owk1n";
    repo = "nvs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Mz5ScSWC0vAavWS2ZKn58b+k4IxlMLxhaxI1B9v76jg=";
  };

  # Completions
  nativeBuildInputs = [
    installShellFiles
    writableTmpDirAsHomeHook
  ];

  vendorHash = "sha256-KQVszK0LLMvi+5aWUVmTTGdUsqJrTWRLe2meb2qV2G0=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd nvs \
      --bash <($out/bin/nvs completion bash) \
      --fish <($out/bin/nvs completion fish) \
      --zsh <($out/bin/nvs completion zsh)
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Lightweight Neovim Version & Config Manager CLI tool to install, switch, list, uninstall, and reset Neovim versions";
    homepage = "https://github.com/y3owk1n/nvs";
    changelog = "https://github.com/y3owk1n/nvs/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      cupcakearmy
    ];

    mainProgram = "nvs";
  };
})
