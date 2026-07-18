{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "tailscale-exporter";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "adinhodovic";
    repo = "tailscale-exporter";
    tag = finalAttrs.version;
    hash = "sha256-uxCcJCmjGiWAzl/vOaynTnIwwuEROXhGJ7MAZMM1I6c=";
  };

  vendorHash = "sha256-gNGQsJjf5CTxZnkIlteLaRKfQlvOE0GtDyWojzffOH4=";
  env.CGO_ENABLED = 0;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/tailscale-exporter"
    "collector"
  ];

  versionCheckProgramArg = "version";

  passthru.tests = {
    inherit (nixosTests.prometheus-exporters) tailscale;
  };

  meta = {
    description = "Tailscale Tailnet metric exporter for Prometheus";
    homepage = "https://github.com/adinhodovic/tailscale-exporter";
    changelog = "https://github.com/adinhodovic/tailscale-exporter/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      squat
    ];

    mainProgram = "tailscale-exporter";
  };
})
