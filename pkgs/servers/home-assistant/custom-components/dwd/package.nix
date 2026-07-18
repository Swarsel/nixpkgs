{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  defusedxml,
}:

buildHomeAssistantComponent rec {
  version = "2026.2.0";

  src = fetchFromGitHub {
    owner = "hg1337";
    repo = "homeassistant-dwd";
    rev = version;
    hash = "sha256-dH2TRNInfbZWS0IlNtAsL4Cxg2fCtopgFILUCyNz4NE=";
  };

  dependencies = [ defusedxml ];
  domain = "dwd";
  # defusedxml version mismatch
  dontCheckManifest = true;
  owner = "hg1337";

  meta = {
    description = "Custom component for Home Assistant that integrates weather data (measurements and forecasts) of Deutscher Wetterdienst";
    homepage = "https://github.com/hg1337/homeassistant-dwd";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      hexa
      emilylange
    ];
  };
}
