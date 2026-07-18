{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "routedns";
  version = "0.1.209";

  src = fetchFromGitHub {
    owner = "folbricht";
    repo = "routedns";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fzBiF0xIArHchV2umdiO6Q2LPe/nZ7QUVKa2w7onO/0=";
  };

  vendorHash = "sha256-e19ZqeVA+WQOILZrju7xFDii/lxmZceXk30tWY74cmM=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "./cmd/routedns" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "DNS stub resolver, proxy and router";
    homepage = "https://github.com/folbricht/routedns";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jsimonetti ];
    mainProgram = "routedns";
  };
})
