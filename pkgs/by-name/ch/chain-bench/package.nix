{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "chain-bench";
  version = "0.1.10";

  src = fetchFromGitHub {
    owner = "aquasecurity";
    repo = "chain-bench";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-5+jSbXbT1UwHMVeZ07qcY8Is88ddHdr7QlgcbQK+8FA=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-uN4TSAxb229NhcWmiQmWBajla9XKnpiZrXOWJxt/mic=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd chain-bench \
      --bash <($out/bin/chain-bench completion bash) \
      --fish <($out/bin/chain-bench completion fish) \
      --zsh <($out/bin/chain-bench completion zsh)
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/chain-bench --help
    $out/bin/chain-bench --version | grep "v${finalAttrs.version}"
    runHook postInstallCheck
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
  ];

  meta = {
    description = "Open-source tool for auditing your software supply chain stack for security compliance based on a new CIS Software Supply Chain benchmark";

    longDescription = ''
      Chain-bench is an open-source tool for auditing your software supply chain
      stack for security compliance based on a new CIS Software Supply Chain
      benchmark. The auditing focuses on the entire SDLC process, where it can
      reveal risks from code time into deploy time. To win the race against
      hackers and protect your sensitive data and customer trust, you need to
      ensure your code is compliant with your organization's policies.
    '';

    homepage = "https://github.com/aquasecurity/chain-bench";
    changelog = "https://github.com/aquasecurity/chain-bench/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jk ];
    mainProgram = "chain-bench";
  };
})
