{
  lib,
  buildGoModule,
  tailscale,
}:

buildGoModule {
  inherit (tailscale) version;
  # It's hosted in the `tailscale` monorepo.
  inherit (tailscale) src vendorHash;
  pname = "tailscale-gitops-pusher";

  env = {
    inherit (tailscale) CGO_ENABLED;
  };

  ldflags = [
    "-w"
    "-s"
    "-X tailscale.com/version.longStamp=${tailscale.version}"
    "-X tailscale.com/version.shortStamp=${tailscale.version}"
  ];

  subPackages = [
    "cmd/gitops-pusher"
  ];

  meta = {
    description = "Allows users to use a GitOps flow for managing Tailscale ACLs";
    homepage = "https://tailscale.com";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      e1mo
      xanderio
    ];

    mainProgram = "gitops-pusher";
  };
}
