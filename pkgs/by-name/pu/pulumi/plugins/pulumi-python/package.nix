{
  lib,
  bash,
  buildGoModule,
  callPackage,
  pulumi,
  python3,
}:
buildGoModule (finalAttrs: {
  inherit (pulumi) version src;
  pname = "pulumi-python";

  # For patchShebangsAuto (see scripts copied in postInstall).
  buildInputs = [
    bash
    python3
  ];

  vendorHash = "sha256-BfkjDesPdPDV2uILYaMJFIvaEBKT15ukwaReAL3yziw=";

  nativeCheckInputs = [
    python3
  ];

  checkFlags = [
    "-skip=^${
      lib.concatStringsSep "$|^" [
        "TestLanguage"
        "TestDeterminePulumiPackages"
      ]
    }$"
  ];

  postInstall = ''
    cp -t "$out/bin" \
      ../pulumi-language-python-exec \
      ../../dist/pulumi-resource-pulumi-python \
      ../../dist/pulumi-analyzer-policy-python
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/pulumi/pulumi/sdk/v3/go/common/version.Version=${finalAttrs.version}"
  ];

  sourceRoot = "${finalAttrs.src.name}/sdk/python/cmd/pulumi-language-python";
  passthru.tests.smokeTest = callPackage ./smoke-test/default.nix { };

  meta = {
    description = "Language host for Pulumi programs written in Python";
    homepage = "https://www.pulumi.com/docs/iac/languages-sdks/python/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      tie
    ];

    mainProgram = "pulumi-language-python";
  };
})
