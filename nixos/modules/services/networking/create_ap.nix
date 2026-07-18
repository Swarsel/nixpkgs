{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.create_ap;
  configFile = pkgs.writeText "create_ap.conf" (lib.generators.toKeyValue { } cfg.settings);
in
{
  options = {
    services.create_ap = {
      enable = lib.mkEnableOption "setting up wifi hotspots using create_ap";

      settings = lib.mkOption {
        default = { };

        description = ''
          Configuration for `create_ap`.
          See [upstream example configuration](https://raw.githubusercontent.com/lakinduakash/linux-wifi-hotspot/master/src/scripts/create_ap.conf)
          for supported values.
        '';

        example = {
          INTERNET_IFACE = "eth0";
          PASSPHRASE = "12345678";
          SSID = "My Wifi Hotspot";
          WIFI_IFACE = "wlan0";
        };

        type =
          with lib.types;
          attrsOf (oneOf [
            int
            bool
            str
          ]);
      };
    };
  };

  config = lib.mkIf cfg.enable {

    systemd = {
      services.create_ap = {
        after = [ "network.target" ];
        description = "Create AP Service";
        restartTriggers = [ configFile ];

        serviceConfig = {
          ExecStart = "${pkgs.linux-wifi-hotspot}/bin/create_ap --config ${configFile}";
          KillSignal = "SIGINT";
          Restart = "on-failure";
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

  };

  meta.maintainers = with lib.maintainers; [ onny ];

}
