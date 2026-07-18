{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "jsonschema";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "santhosh-tekuri";
    repo = "jsonschema";
    tag = "cmd/jv/v${finalAttrs.version}";
    hash = "sha256-bMDDji5daBmjSeGxeS4PZfmTg+b8OVHsP8+m3jtpQJc=";
  };

  vendorHash = "sha256-s7kEdA4yuExuzwN3hHgeZmtkES3Zw1SALoEHSNtdAww=";
  env.GOWORK = "off";

  ldflags = [
    "-s"
    "-w"
  ];

  sourceRoot = "${finalAttrs.src.name}/cmd/jv";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=cmd/jv/v([\\d\\.]+)" ];
  };

  meta = {
    description = "JSON schema compilation and validation";
    homepage = "https://github.com/santhosh-tekuri/jsonschema";
    changelog = "https://github.com/santhosh-tekuri/jsonschema/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ibizaman ];
    mainProgram = "jv";
  };
})
