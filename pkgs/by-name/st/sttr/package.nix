{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "sttr";
  version = "0.2.30";

  src = fetchFromGitHub {
    owner = "abhimanyu003";
    repo = "sttr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oZsciY9JCU1YjkhT6LEDclNC0ixOuZST5dnI9n0uzfo=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-nVocBBMOVW4q55dkVnmySozCsAbNnYjgPjoWDsAl7Uo=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd sttr \
      --bash <($out/bin/sttr completion bash) \
      --fish <($out/bin/sttr completion fish) \
      --zsh <($out/bin/sttr completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Cross-platform cli tool to perform various operations on string";
    homepage = "https://github.com/abhimanyu003/sttr";
    changelog = "https://github.com/abhimanyu003/sttr/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Ligthiago ];
    mainProgram = "sttr";
  };
})
