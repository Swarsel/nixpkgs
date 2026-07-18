{
  lib,
  mkPulumiPackage,
  python3Packages,
}:
mkPulumiPackage rec {
  version = "4.25.0";
  vendorHash = "sha256-L4kJ+oKciJO0B05rcs4lbKpcINxC3gmvR0lC+LdSNeo=";
  cmdGen = "pulumi-gen-kubernetes";
  cmdRes = "pulumi-resource-kubernetes";

  extraLdflags = [
    "-X=github.com/pulumi/${repo}/provider/pkg/version.Version=${version}"
  ];

  hash = "sha256-CkNTMeiiM8Q4eIEugmid7IKVHplhOAg8YaANSEFodxE=";
  owner = "pulumi";

  pythonArgs.dependencies = with python3Packages; [
    requests
  ];

  repo = "pulumi-kubernetes";
  rev = "v${version}";

  meta = {
    description = "Kubernetes resource package, for the Pulumi infrastructure-as-code toolchain";
    homepage = "https://www.pulumi.com/docs/reference/clouds/kubernetes/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nicoo ];
    mainProgram = "pulumi-resource-kubernetes";
  };
}
