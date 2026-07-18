{
  lib,
  mkPulumiPackage,
}:
mkPulumiPackage rec {
  version = "2.13.0";
  vendorHash = "sha256-20wHbNE/fenxP9wgTSzAnx6b1UYlw4i1fi6SesTs0sc=";

  postConfigure = ''
    pushd ..

    chmod +w . provider/cmd/${cmdRes} sdk/
    chmod -R +w reports/ versions/
    mkdir bin
    ${cmdGen} schema ${version}

    cp bin/schema-full.json provider/cmd/${cmdRes}
    cp bin/metadata-compact.json provider/cmd/${cmdRes}

    popd

    VERSION=v${version} go generate cmd/${cmdRes}/main.go
  '';

  __darwinAllowLocalNetworking = true;
  cmdGen = "pulumi-gen-azure-native";
  cmdRes = "pulumi-resource-azure-native";

  extraLdflags = [
    "-X github.com/pulumi/${repo}/v2/provider/pkg/version.Version=${version}"
  ];

  fetchSubmodules = true;
  hash = "sha256-YyJxACeXyY7hZkTbLXT/ASNWa1uv9h3cvPoItR183fU=";
  owner = "pulumi";
  repo = "pulumi-azure-native";
  rev = "v${version}";

  meta = {
    description = "Native Azure Pulumi Provider";
    homepage = "https://github.com/pulumi/pulumi-azure-native";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      veehaitch
    ];

    mainProgram = "pulumi-resource-azure-native";
  };
}
