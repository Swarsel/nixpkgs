{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "prometheus-storagebox-exporter";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "fleaz";
    repo = "prometheus-storagebox-exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sufxNnHAdOaYEzKj9vriDrJF6Tq4Eim3Z45FEuuG97Q=";
  };

  vendorHash = "sha256-hWM7JnL0x+vsUrQsJZGM3z2jB3F1wtjKWmX8j+WnjKY=";

  meta = {
    description = "Prometheus exporter for Hetzner storage boxes";
    homepage = "https://github.com/fleaz/prometheus-storagebox-exporter";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      erethon
      fleaz
    ];

    mainProgram = "prometheus-storagebox-exporter";
  };
})
