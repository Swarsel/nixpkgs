{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "deck";
  version = "1.64.0";

  src = fetchFromGitHub {
    owner = "Kong";
    repo = "deck";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nVV1nNOQ5zqywUXg3vdyiudryWVRKiDWU0Yc8b0albo=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-lo+1ijaWod0UB2PXzmg806q2KYrVu9yNgkI/Nq2lyq4=";
  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd deck \
      --bash <($out/bin/deck completion bash) \
      --fish <($out/bin/deck completion fish) \
      --zsh <($out/bin/deck completion zsh)
  '';

  ldflags = [
    "-s -w -X github.com/kong/deck/cmd.VERSION=${finalAttrs.version}"
    "-X github.com/kong/deck/cmd.COMMIT=${finalAttrs.src.rev}"
  ];

  proxyVendor = true; # darwin/linux hash mismatch
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Configuration management and drift detection tool for Kong";
    homepage = "https://github.com/Kong/deck";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ liyangau ];
    mainProgram = "deck";
  };
})
