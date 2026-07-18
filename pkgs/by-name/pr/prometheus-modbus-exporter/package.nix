{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-modbus-exporter";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "richih";
    repo = "modbus_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZkES+CDthYZrNZ7wVO0oRx6pBMX23AyUOhU+OBTD42g=";
  };

  vendorHash = "sha256-RfpJLoYPR5Ura3GvLIAePg+fuiaiXig6XaSNCPhZ/Vg=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/prometheus/common/version.BuildDate=1970-01-01T00:00:00Z"
    "-X github.com/prometheus/common/version.BuildUser=nix@nixpkgs"
    "-X github.com/prometheus/common/version.Branch=master"
    "-X github.com/prometheus/common/version.Revision=${finalAttrs.src.rev}"
    "-X github.com/prometheus/common/version.Version=${finalAttrs.version}"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Exporter which retrieves stats from a modbus system and exports them via HTTP for Prometheus consumption";
    homepage = "https://github.com/richih/modbus_exporter";
    changelog = "https://github.com/richih/modbus_exporter/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ paepcke ];
    mainProgram = "modbus_exporter";
  };
})
