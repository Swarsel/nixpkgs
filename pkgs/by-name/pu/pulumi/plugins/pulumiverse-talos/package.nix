{
  lib,
  mkPulumiPackage,
}:
mkPulumiPackage rec {
  version = "0.7.1";
  vendorHash = "sha256-1xAIb7ZSsTqlVBpgFHc3RdQkNDngDT7A6tu7gEiGKjY=";
  cmdGen = "pulumi-tfgen-talos";
  cmdRes = "pulumi-resource-talos";

  extraLdflags = [
    "-X=github.com/${owner}/${repo}/provider/pkg/version.Version=${version}"
  ];

  hash = "sha256-mk56p7vle61NdRKEaC8v0Eh9aJiilwdaDMwVvLaVRIM=";
  owner = "pulumiverse";
  pythonArgs.pname = "pulumiverse_talos";
  repo = "pulumi-talos";
  rev = "v${version}"; # TODO: add support for `tag`

  meta = {
    description = "Talos Linux resource package, providing IaC configuration of Talos k8s clusters";
    homepage = "https://www.pulumi.com/registry/packages/talos/";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      nicoo
    ];

    mainProgram = cmdRes;
  };
}
