{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:
buildGoModule (finalAttrs: {
  pname = "kconf";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "particledecay";
    repo = "kconf";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-bLyLXkXOZRFaplv5sY0TgFffvbA3RUwz6b+7h3MN7kA=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-REguLiYlcC2Q6ao2oMl92/cznW+E8MO2UGhQKRXZ1vQ=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd kconf \
      --bash <($out/bin/kconf completion bash) \
      --fish <($out/bin/kconf completion fish) \
      --zsh <($out/bin/kconf completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/particledecay/kconf/build.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Opinionated command line tool for managing multiple kubeconfigs";
    homepage = "https://github.com/particledecay/kconf";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      thmzlt
      sailord
      vinetos
    ];

    mainProgram = "kconf";
  };
})
