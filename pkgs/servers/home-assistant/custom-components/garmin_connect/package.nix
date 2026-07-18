{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  ha-garmin,
}:

buildHomeAssistantComponent rec {
  version = "3.0.13";

  src = fetchFromGitHub {
    owner = "cyberjunky";
    repo = "home-assistant-garmin_connect";
    tag = version;
    hash = "sha256-qba1aexMT02dUob4ITS1ePLB41WBleZEdKsWuXCx6+o=";
  };

  dependencies = [
    ha-garmin
  ];

  domain = "garmin_connect";
  # home-assistant-garmin_connect pins an exact version of ha-garmin, but we
  # want to allow newer, compatible versions to be used.
  ignoreVersionRequirement = [ "ha-garmin" ];
  owner = "cyberjunky";

  meta = {
    description = "Garmin Connect integration allows you to expose data from Garmin Connect to Home Assistant";
    homepage = "https://github.com/cyberjunky/home-assistant-garmin_connect";
    changelog = "https://github.com/cyberjunky/home-assistant-garmin_connect/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      matthiasbeyer
      dmadisetti
    ];
  };
}
