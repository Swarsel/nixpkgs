{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "turso-cli";
  version = "1.0.29";

  src = fetchFromGitHub {
    owner = "tursodatabase";
    repo = "turso-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jsvXglCf/FyJ3tasnOywXLA20k94yzbojPdX+dZVPfw=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-4OIJVL3N2mWOw7ZDP4xFCxa9zmUTPCA8N79TVoi1lys=";

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd turso \
      --bash <($out/bin/turso completion bash) \
      --fish <($out/bin/turso completion fish) \
      --zsh <($out/bin/turso completion zsh)
  '';

  ldflags = [
    "-X github.com/tursodatabase/turso-cli/internal/cmd.version=v${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for Turso";
    homepage = "https://turso.tech";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      zestsystem
      kashw2
      fryuni
    ];

    mainProgram = "turso";
  };
})
