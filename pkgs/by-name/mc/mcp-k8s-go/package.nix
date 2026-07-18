{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "mcp-k8s-go";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "strowk";
    repo = "mcp-k8s-go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/5tmKngZTp5n8jDZwKAaG4ad+MPRFEJfgV/A5TMVLlM=";
  };

  vendorHash = "sha256-WULy61Ntra9Jz4fhSVOzftzWyQxvPFyBfjuKlKTORqI=";
  doCheck = false;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "MCP server connecting to Kubernetes";
    homepage = "https://github.com/strowk/mcp-k8s-go";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pilz ];
    mainProgram = "mcp-k8s-go";
  };
})
