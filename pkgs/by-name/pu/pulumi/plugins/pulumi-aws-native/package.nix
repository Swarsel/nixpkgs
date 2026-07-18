{
  lib,
  mkPulumiPackage,
}:
mkPulumiPackage rec {
  version = "0.38.0";
  vendorHash = "sha256-Yu9tNakwXWYdrjzI6/MFRzVBhJAEOjsmq9iBAQlR0AI=";

  postConfigure = ''
    pushd ..

    ${cmdGen} schema aws-cloudformation-schema ${version}

    popd
  '';

  __darwinAllowLocalNetworking = true;
  cmdGen = "pulumi-gen-aws-native";
  cmdRes = "pulumi-resource-aws-native";

  extraLdflags = [
    "-X github.com/pulumi/${repo}/provider/pkg/version.Version=v${version}"
  ];

  fetchSubmodules = true;
  hash = "sha256-v7jNPCrjtfi9KYD4RhiphMIpV23g/CBV/sKPBkMulu0=";
  owner = "pulumi";
  repo = "pulumi-aws-native";
  rev = "v${version}";

  meta = {
    description = "Native AWS Pulumi Provider";
    homepage = "https://github.com/pulumi/pulumi-aws-native";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      veehaitch
    ];

    mainProgram = "pulumi-resource-aws-native";
  };
}
