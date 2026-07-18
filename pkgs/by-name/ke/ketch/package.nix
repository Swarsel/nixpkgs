{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "ketch";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "1broseidon";
    repo = "ketch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m6KEPbNd13eJsNigJyGGlV2dt0bcZTZcDBCBh/l5rjY=";
  };

  strictDeps = true;
  vendorHash = "sha256-UsTR7+GSuxUQ0aBq8fv1M18LegeDqf/XoiyASQKe5EI=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/1broseidon/ketch/cmd.version=${finalAttrs.version}"
  ];

  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast, stateless CLI for web search and scrape. Built for AI agents.";
    homepage = "https://chain.sh/ketch/";
    changelog = "https://github.com/1broseidon/ketch/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      stephsi
    ];

    mainProgram = "ketch";
  };
})
