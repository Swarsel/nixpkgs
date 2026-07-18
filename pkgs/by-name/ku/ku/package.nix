{
  lib,
  fetchFromGitHub,
  buildGo126Module,
  nix-update-script,
  versionCheckHook,
}:

buildGo126Module (finalAttrs: {
  pname = "ku";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "bjarneo";
    repo = "ku";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vUv4eKTCucJ/ol76z0Q3jOigYBSwM823ZxjvBFqv1yY=";
  };

  vendorHash = "sha256-x7O2/uKnIIFDr8WK0ej3FJiIGxN5Fq5Czqrv4OJ5A44=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
  ];

  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast, keyboard-driven Kubernetes TUI";
    homepage = "https://github.com/bjarneo/ku";
    changelog = "https://github.com/bjarneo/ku/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kevinpita ];
    platforms = lib.platforms.unix;
    mainProgram = "ku";
  };
})
