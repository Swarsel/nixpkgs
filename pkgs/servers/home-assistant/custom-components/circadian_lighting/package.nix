{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  nix-update-script,
}:

buildHomeAssistantComponent rec {
  version = "2.1.6";

  src = fetchFromGitHub {
    owner = "claytonjn";
    repo = "hass-circadian_lighting";
    tag = version;
    hash = "sha256-6S1wIO6UgPdUPt9oDCzIb4duUOql4KgnTd6MjRhrSb0=";
  };

  domain = "circadian_lighting";
  owner = "claytonjn";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Circadian Lighting custom component for Home Assistant";
    homepage = "https://github.com/claytonjn/hass-circadian_lighting";
    changelog = "https://github.com/claytonjn/hass-circadian_lighting/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jpds ];
  };
}
