{
  lib,
  mkPulumiPackage,
}:
mkPulumiPackage rec {
  version = "5.4.0";
  vendorHash = "sha256-dabWCYvIvPeHgbDGlgULAyLAARO5IYqYnSkUs5p6/PM=";
  __darwinAllowLocalNetworking = true;
  cmdGen = "pulumi-tfgen-linode";
  cmdRes = "pulumi-resource-linode";

  extraLdflags = [
    "-X=github.com/pulumi/${repo}/provider/v5/pkg/version.Version=v${version}"
  ];

  hash = "sha256-XfZKiGODCncvbHRc4EuwItMWuJyliFxud5GO2X4h1qg=";
  owner = "pulumi";
  repo = "pulumi-linode";
  rev = "v${version}";

  meta = {
    description = "Linode Pulumi resource package, providing multi-language access to Linode";
    homepage = "https://github.com/pulumi/pulumi-linode";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ purcell ];
    mainProgram = "pulumi-resource-linode";
  };
}
