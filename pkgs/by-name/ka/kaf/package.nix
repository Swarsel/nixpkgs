{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "kaf";
  version = "0.2.14";

  src = fetchFromGitHub {
    owner = "birdayz";
    repo = "kaf";
    rev = "v${finalAttrs.version}";
    hash = "sha256-gLFUv+4wGH1FOpa4DHHwSV7nSCxo+MzdNmo0I0SD/p0=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-U4nmC08z7xtvRdy2xzvBqTmxJhQKI0BjJDkUwDZOQg0=";
  # Many tests require a running Kafka instance
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd kaf \
      --bash <($out/bin/kaf completion bash) \
      --zsh <($out/bin/kaf completion zsh) \
      --fish <($out/bin/kaf completion fish)
  '';

  meta = {
    description = "Modern CLI for Apache Kafka, written in Go";
    homepage = "https://github.com/birdayz/kaf";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ zarelit ];
    mainProgram = "kaf";
  };
})
