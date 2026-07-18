{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "opensearch-cli";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "opensearch-project";
    repo = "opensearch-cli";
    rev = finalAttrs.version;
    hash = "sha256-Ah64a9hpc2tnIXiwxg/slE6fUTAoHv9koNmlUHrVj/s=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-r3Bnud8pd0Z9XmGkj9yxRW4U/Ry4U8gvVF4pAdN14lQ=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    export HOME="$(mktemp -d)"
    installShellCompletion --cmd opensearch-cli \
      --bash <($out/bin/opensearch-cli completion bash) \
      --zsh <($out/bin/opensearch-cli completion zsh) \
      --fish <($out/bin/opensearch-cli completion fish)
  '';

  meta = {
    description = "Full-featured command line interface (CLI) for OpenSearch";
    homepage = "https://github.com/opensearch-project/opensearch-cli";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "opensearch-cli";
  };
})
