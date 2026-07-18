{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "gitsnip";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "dagimg-dot";
    repo = "gitsnip";
    tag = "v${finalAttrs.version}";
    hash = "sha256-90lM9MPX45W513EQ5qH+s86nIWjTpQw6OIAzvTLU+4w=";
  };

  vendorHash = "sha256-m5mBubfbXXqXKsygF5j7cHEY+bXhAMcXUts5KBKoLzM=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s -w"
    "-X github.com/dagimg-dot/gitsnip/internal/cli.version=${finalAttrs.version}"
    "-X github.com/dagimg-dot/gitsnip/internal/cli.commit=refs/tags/v${finalAttrs.version}"
    "-X github.com/dagimg-dot/gitsnip/internal/cli.builtBy=nixpkgs"
  ];

  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI tool to download specific folders from a git repository";
    homepage = "https://github.com/dagimg-dot/gitsnip/";
    changelog = "https://github.com/dagimg-dot/gitsnip/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      adda
    ];

    mainProgram = "gitsnip";
  };
})
