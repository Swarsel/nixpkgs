{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "mweinelt";
    repo = "ha-prometheus-sensor";
    tag = version;
    hash = "sha256-uIC/yGqjigVURZYVMMLY33VqRbadSCqTtT0Qtaq71uc=";
  };

  domain = "prometheus_sensor";
  owner = "mweinelt";

  meta = {
    description = "Import prometheus query results into Home Assistant";
    homepage = "https://github.com/mweinelt/ha-prometheus-sensor";
    changelog = "https://github.com/mweinelt/ha-prometheus-sensor/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
