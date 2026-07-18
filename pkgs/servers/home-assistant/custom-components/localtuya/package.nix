{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "2025.11.0";

  src = fetchFromGitHub {
    owner = "xZetsubou";
    repo = "hass-localtuya";
    tag = version;
    hash = "sha256-TISiZchkLZ3AaNh622nolIyBjDgdJBQrc30oBHN/INE=";
  };

  domain = "localtuya";
  owner = "xZetsubou";

  meta = {
    description = "Home Assistant custom Integration for local handling of Tuya-based devices, fork from local-tuya";
    homepage = "https://github.com/xZetsubou/hass-localtuya";
    changelog = "https://github.com/xZetsubou/hass-localtuya/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ rhoriguchi ];
  };
}
