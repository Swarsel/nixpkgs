{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:
buildHomeAssistantComponent rec {
  version = "2026.01.1";

  src = fetchFromGitHub {
    owner = "Hypfer";
    repo = "hass-valetudo";
    tag = "${version}";
    hash = "sha256-xJ8kA+ujWuen5660GWZSo90WsHpfwQVStIheaIRxAg8=";
  };

  domain = "valetudo";
  owner = "Hypfer";

  meta = {
    description = "Valetudo for Home Assistant";
    homepage = "https://github.com/Hypfer/hass-valetudo";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ benediktbroich ];
  };
}
