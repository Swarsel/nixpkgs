{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "sshportal";
  version = "1.19.5";

  src = fetchFromGitHub {
    owner = "moul";
    repo = "sshportal";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-XJ8Hgc8YoJaH2gYOvoYhcpY4qgasgyr4M+ecKJ/RXTs=";
  };

  vendorHash = "sha256-4dMZwkLHS14OGQVPq5VaT/aEpHEJ/4b2P6q3/WiDicM=";

  ldflags = [
    "-X main.GitTag=${finalAttrs.version}"
    "-X main.GitSha=${finalAttrs.version}"
    "-s"
    "-w"
  ];

  meta = {
    description = "Simple, fun and transparent SSH (and telnet) bastion server";
    homepage = "https://manfred.life/sshportal";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ zaninime ];
    mainProgram = "sshportal";
  };
})
