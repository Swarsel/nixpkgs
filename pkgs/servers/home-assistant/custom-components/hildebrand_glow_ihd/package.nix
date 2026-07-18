{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  nix-update-script,
}:

buildHomeAssistantComponent rec {
  version = "1.8.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "ha_hildebrand_glow_ihd_mqtt";
    tag = "v${version}";
    hash = "sha256-13NmNHaCYDZkWK5uqKeTZlB84UuThNLOAYaPS4QfTKY=";
  };

  domain = "hildebrand_glow_ihd";
  owner = "megakid";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Home Assistant integration for local MQTT Hildebrand Glow IHD";
    homepage = "https://github.com/megakid/ha_hildebrand_glow_ihd_mqtt";
    changelog = "https://github.com/megakid/ha_hildebrand_glow_ihd_mqtt/releases/tag/${src.tag}";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ CodedNil ];
  };
}
