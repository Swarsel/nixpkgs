{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "github-mcp-server";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "github";
    repo = "github-mcp-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-O8ooNaFmWXMhsn7UQITgo48VkdYbVTCC4WkHoU9abyo=";
  };

  vendorHash = "sha256-J1hC4hdEKLENXLJrsyV41TaJ9+2CuPz5KoIMm2mXvTE=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
    "-X=main.commit=${finalAttrs.src.rev}"
    "-X=main.date=1970-01-01T00:00:00Z"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GitHub's official MCP Server";
    homepage = "https://github.com/github/github-mcp-server";
    changelog = "https://github.com/github/github-mcp-server/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ logger ];
    mainProgram = "github-mcp-server";
  };
})
