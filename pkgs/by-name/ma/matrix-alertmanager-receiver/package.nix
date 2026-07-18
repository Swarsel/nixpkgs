{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "matrix-alertmanager-receiver";
  version = "2026.7.8";

  src = fetchFromGitHub {
    owner = "metio";
    repo = "matrix-alertmanager-receiver";
    tag = finalAttrs.version;
    hash = "sha256-BOPdEgAhzY5o4YaPxVKkwsWZRdsaymAK0c13FTmLzMQ=";
  };

  vendorHash = "sha256-hVJZ+SoWCe9juq5ut7yHr+4nshORH1uHLIPCzpB+4Nc=";
  env.CGO_ENABLED = "0";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-X main.matrixAlertmanagerReceiverVersion=${finalAttrs.version}"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Alertmanager client that forwards alerts to a Matrix room";
    homepage = "https://github.com/metio/matrix-alertmanager-receiver";
    changelog = "https://github.com/metio/matrix-alertmanager-receiver/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ liberodark ];
    mainProgram = "matrix-alertmanager-receiver";
  };
})
