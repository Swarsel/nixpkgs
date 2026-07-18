{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "vendir";
  version = "0.46.0";

  src = fetchFromGitHub {
    owner = "vmware-tanzu";
    repo = "carvel-vendir";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-X9tyEeE6QrUQaRlbhRkd+Lz7+bFJrWO2Dn8e0ax7Pdg=";
  };

  vendorHash = null;

  ldflags = [
    "-X carvel.dev/vendir/pkg/vendir/version.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/vendir" ];

  meta = {
    description = "CLI tool to vendor portions of git repos, github releases, helm charts, docker image contents, etc. declaratively";
    homepage = "https://carvel.dev/vendir/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ russell ];
    mainProgram = "vendir";
  };
})
