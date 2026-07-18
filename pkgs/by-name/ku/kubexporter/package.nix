{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "kubexporter";
  version = "0.8.8";

  src = fetchFromGitHub {
    owner = "bakito";
    repo = "kubexporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PD/mvjL5Xp7gAs3iIz8nhsW7cpenFyzYiEXHE/zmur4=";
  };

  vendorHash = "sha256-FToKA1Zu8wj5CudxYmtggvBZmuQLYWWg2taswPnMuDA=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/bakito/kubexporter/version.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool for exporting Kubernetes resources as YAML or JSON files";
    homepage = "https://github.com/bakito/kubexporter";
    changelog = "https://github.com/bakito/kubexporter/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bakito ];
    mainProgram = "kubexporter";
  };
})
