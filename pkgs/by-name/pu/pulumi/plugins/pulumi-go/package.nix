{
  lib,
  buildGoModule,
  pulumi,
}:
buildGoModule (finalAttrs: {
  inherit (pulumi) version src;
  pname = "pulumi-go";
  vendorHash = "sha256-jwsdMSLDn2PNJFIIVhqwBLH7acFTOFLPgVNMKbI5DZE=";

  checkFlags = [
    "-skip=^${
      lib.concatStringsSep "$|^" [
        "TestLanguage"
        "TestPluginsAndDependencies_vendored"
        "TestPluginsAndDependencies_subdir"
        "TestPluginsAndDependencies_moduleMode"
      ]
    }$"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/pulumi/pulumi/sdk/v3/go/common/version.Version=${finalAttrs.version}"
  ];

  sourceRoot = "${finalAttrs.src.name}/sdk/go/pulumi-language-go";

  meta = {
    description = "Language host for Pulumi programs written in Go";
    homepage = "https://www.pulumi.com/docs/iac/languages-sdks/go/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      tie
    ];

    mainProgram = "pulumi-language-go";
  };
})
