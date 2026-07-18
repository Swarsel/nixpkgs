{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  # dependencies
  tinytuya,
  tuya-device-sharing-sdk,
}:

buildHomeAssistantComponent rec {
  version = "2026.7.1";

  src = fetchFromGitHub {
    inherit owner;
    repo = "tuya-local";
    tag = version;
    hash = "sha256-NljzFG1uEg0J1eSXdPeZqPnA3eBrurUvHaAdnUffjgY=";
  };

  dependencies = [
    tinytuya
    tuya-device-sharing-sdk
  ];

  domain = "tuya_local";
  owner = "make-all";

  meta = {
    description = "Local support for Tuya devices in Home Assistant";
    homepage = "https://github.com/make-all/tuya-local";
    changelog = "https://github.com/make-all/tuya-local/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pathob ];
  };
}
