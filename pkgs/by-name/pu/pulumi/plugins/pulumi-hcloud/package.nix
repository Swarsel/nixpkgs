{
  lib,
  mkPulumiPackage,
}:
mkPulumiPackage rec {
  version = "1.20.4";
  vendorHash = "sha256-u3mxaOEXQod1MDFxo85YdOb6Bx/9G5uaa3ykhnmcqCg=";
  __darwinAllowLocalNetworking = true;
  cmdGen = "pulumi-tfgen-hcloud";
  cmdRes = "pulumi-resource-hcloud";

  extraLdflags = [
    "-X=github.com/pulumi/${repo}/provider/pkg/version.Version=v${version}"
  ];

  hash = "sha256-m9MRXDTSC0K1raoH9gKPuxdwvUEnZ/ulp32xlY1Hsdo=";
  owner = "pulumi";
  repo = "pulumi-hcloud";
  rev = "v${version}";

  meta = {
    description = "Hetzner Cloud Pulumi resource package, providing multi-language access to Hetzner Cloud";
    homepage = "https://github.com/pulumi/pulumi-hcloud";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ tie ];
    mainProgram = "pulumi-resource-hcloud";
  };
}
