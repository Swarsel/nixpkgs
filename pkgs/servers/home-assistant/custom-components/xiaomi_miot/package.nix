{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  construct,
  micloud,
  nix-update-script,
  python-miio,
}:

buildHomeAssistantComponent rec {
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "al-one";
    repo = "hass-xiaomi-miot";
    rev = "v${version}";
    hash = "sha256-t1kOPiZR0CxOsp2V4cJNi+aiDdr7VhqhX8jOAiKTemk=";
  };

  dependencies = [
    construct
    micloud
    python-miio
  ];

  domain = "xiaomi_miot";
  owner = "al-one";
  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=^v([0-9.]+)$" ]; };

  meta = {
    description = "Automatic integrate all Xiaomi devices to HomeAssistant via miot-spec, support Wi-Fi, BLE, ZigBee devices";

    longDescription = ''
      Xiaomi Miot For HomeAssistant depends on `ffmpeg` and `homekit`, example how to setup in NixOS `configuration.nix`:

      ```
      { config, lib, pkgs, ... }:
      {
        services.home-assistant = {
          customComponents = [ pkgs.home-assistant-custom-components.xiaomi_miot ];
          extraComponents = [ "ffmpeg" "homekit" ];
        };
      }
      ```
    '';

    homepage = "https://github.com/al-one/hass-xiaomi-miot";
    changelog = "https://github.com/al-one/hass-xiaomi-miot/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ azuwis ];
  };
}
