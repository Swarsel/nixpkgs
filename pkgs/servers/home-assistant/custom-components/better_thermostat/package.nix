{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  gitUpdater,
}:

buildHomeAssistantComponent rec {
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "KartoffelToby";
    repo = "better_thermostat";
    tag = version;
    hash = "sha256-agGCRIhCVRJWFXdva4lOjeM1Qh7LvYBowGi7LiatnMU=";
  };

  domain = "better_thermostat";
  owner = "KartoffelToby";

  passthru.updateScript = gitUpdater {
    ignoredVersions = "(Alpha|Beta|alpha|beta).*";
  };

  meta = {
    description = "Smart TRV control integrates room-temp sensors, window/door sensors, weather forecasts, and ambient probes for efficient heating and calibration, enhancing energy savings and comfort";
    homepage = "https://better-thermostat.org/";
    changelog = "https://github.com/KartoffelToby/better_thermostat/releases/tag/${version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ mguentner ];
  };
}
