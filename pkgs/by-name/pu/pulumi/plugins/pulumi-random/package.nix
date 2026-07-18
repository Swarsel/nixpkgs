{
  lib,
  mkPulumiPackage,
}:
mkPulumiPackage rec {
  version = "4.14.0";
  vendorHash = "sha256-YDuF89F9+pxVq4TNe5l3JlbcqpnJwSTPAP4TwWTriWA=";
  __darwinAllowLocalNetworking = true;
  cmdGen = "pulumi-tfgen-random";
  cmdRes = "pulumi-resource-random";

  extraLdflags = [
    "-X github.com/pulumi/${repo}/provider/v4/pkg/version.Version=v${version}"
  ];

  hash = "sha256-1MR7zWNBDbAUoRed7IU80PQxeH18x95MKJKejW5m2Rs=";
  owner = "pulumi";
  repo = "pulumi-random";
  rev = "v${version}";

  meta = {
    description = "Pulumi provider that safely enables randomness for resources";
    homepage = "https://github.com/pulumi/pulumi-random";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      veehaitch
    ];

    mainProgram = "pulumi-resource-random";
  };
}
