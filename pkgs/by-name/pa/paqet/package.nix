{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  libpcap,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "paqet";
  version = "1.0.0-alpha.20";

  src = fetchFromGitHub {
    owner = "hanselime";
    repo = "paqet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zBBs2n4wD82xiiwWUlqRtHqRsNOH4B3s+2ssr5FugWo=";
  };

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ libpcap ];
  vendorHash = "sha256-E83qbdQ/OFT7gVPwU4fGvFC7bDDiRVt5e07dA7yJmAY=";

  postInstall = ''
    mv $out/bin/cmd $out/bin/paqet
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd paqet \
      --bash <($out/bin/paqet completion bash) \
      --fish <($out/bin/paqet completion fish) \
      --zsh  <($out/bin/paqet completion zsh)
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=unstable" ]; };

  meta = {
    description = "Bidirectional Packet-level proxy built using raw sockets in Go";
    homepage = "https://github.com/hanselime/paqet";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nix-julia ];
    mainProgram = "paqet";
  };
})
