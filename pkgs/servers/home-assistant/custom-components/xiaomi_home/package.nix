{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  construct,
  cryptography,
  nix-update-script,
  numpy,
  paho-mqtt,
  psutil-home-assistant,
}:

buildHomeAssistantComponent rec {
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "XiaoMi";
    repo = "ha_xiaomi_home";
    rev = "v${version}";
    hash = "sha256-rI7uYYCvTRXcuCOQu052SjNTRUyux0Cp6mIj4WGyTy0=";
  };

  dependencies = [
    construct
    paho-mqtt
    numpy
    cryptography
    psutil-home-assistant
  ];

  domain = "xiaomi_home";
  owner = "XiaoMi";
  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=^v([0-9.]+)$" ]; };

  meta = {
    description = "Xiaomi Home Integration for Home Assistant";

    longDescription = ''
      Xiaomi Home Integration for Home Assistant depends on additional components, example how to setup in NixOS `configuration.nix`:

      ```
      { config, lib, pkgs, ... }:
      {
        services.home-assistant = {
          customComponents = [ pkgs.home-assistant-custom-components.xiaomi_home ];
          extraComponents = [ "ffmpeg" "zeroconf" ];
        };
        # OAuth2 Redirect URL is hardcoded as http://homeassistant.local:8123
        # Make sure you can access HA via this URL with mDNS
        services.avahi.hostName = "homeassistant";
        networking.firewall.allowedTCPPorts = [ 8123 ];
      }
      ```
    '';

    homepage = "https://github.com/XiaoMi/ha_xiaomi_home";
    changelog = "https://github.com/XiaoMi/ha_xiaomi_home/releases/tag/v${version}";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ MakiseKurisu ];
  };
}
