{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lichtteil";
    repo = "local_luftdaten";
    tag = version;
    hash = "sha256-K8sQ/xm9aoJ6EBF9H9Y87m7a0OZN4y6T3DFZcSpPYOI=";
  };

  domain = "local_luftdaten";
  owner = "lichtteil";

  meta = {
    description = "Custom component for Home Assistant that integrates your (own) local Luftdaten sensor (air quality/particle sensor) without using the cloud";
    homepage = "https://github.com/lichtteil/local_luftdaten";
    changelog = "https://github.com/lichtteil/local_luftdaten/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
