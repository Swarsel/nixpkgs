{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "kubectl-gadget";
  version = "0.54.0";

  src = fetchFromGitHub {
    owner = "inspektor-gadget";
    repo = "inspektor-gadget";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T0UywAmNHk+tmE2eHnxHPpOulNAa+juEMqA2Bth044I=";
  };

  vendorHash = "sha256-35bloouMwEuaZOC7ygz3sOJqoJoldDD4XHeCdBxx56U=";
  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/inspektor-gadget/inspektor-gadget/internal/version.version=v${finalAttrs.version}"
    "-X main.gadgetimage=ghcr.io/inspektor-gadget/inspektor-gadget:v${finalAttrs.version}"
    "-extldflags=-static"
  ];

  subPackages = [ "cmd/kubectl-gadget" ];

  tags = [
    "withoutebpf"
  ];

  meta = {
    description = "Collection of gadgets for troubleshooting Kubernetes applications using eBPF";
    homepage = "https://inspektor-gadget.io";
    changelog = "https://github.com/inspektor-gadget/inspektor-gadget/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      kranurag7
      devusb
    ];

    mainProgram = "kubectl-gadget";
  };
})
