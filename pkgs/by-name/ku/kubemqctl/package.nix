{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "kubemqctl";
  version = "3.7.2";

  src = fetchFromGitHub {
    owner = "kubemq-io";
    repo = "kubemqctl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PaB5+Sy2ccEQz+wuz88w/M4NXayKA41/ugSPJdtjfiE=";
  };

  vendorHash = "sha256-rou4IC5wMIq7i/OGAvE28qke0X6C5S7Iw+gwCPf5Zdk=";

  preBuild = ''
    # The go.sum file is missing from the upstream.
    cp ${./go.sum} go.sum
  '';

  doCheck = false; # TODO tests are failing

  ldflags = [
    "-w"
    "-s"
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "CLI for Kubemq Kubernetes Message Broker";
    homepage = "https://github.com/kubemq-io/kubemqctl";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ brianmcgee ];
    mainProgram = "kubemqctl";
  };
})
