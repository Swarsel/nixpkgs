{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "lefthook";
  version = "2.1.5";

  src = fetchFromGitHub {
    owner = "evilmartians";
    repo = "lefthook";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HLC6X9JjiiR3Ecg5MQ33vELs6ooLLjQ9x++4xB1qyHU=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-75jrXoBXoPCE/Ue7OlGAA4nUDXHM5ccIaK4rsKgfG84=";
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd lefthook \
      --bash <($out/bin/lefthook completion bash) \
      --fish <($out/bin/lefthook completion fish) \
      --zsh <($out/bin/lefthook completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Fast and powerful Git hooks manager for any type of projects";
    homepage = "https://github.com/evilmartians/lefthook";
    changelog = "https://github.com/evilmartians/lefthook/raw/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "lefthook";
  };
})
