{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.domoticz;
  pkgDesc = "Domoticz home automation";

in
{

  options = {

    services.domoticz = {
      enable = lib.mkEnableOption pkgDesc;

      bind = lib.mkOption {
        default = "0.0.0.0";
        description = "IP address to bind to.";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 8080;
        description = "Port to bind to for HTTP, set to 0 to disable HTTP.";
        type = lib.types.port;
      };

    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services."domoticz" = {
      after = [ "network-online.target" ];
      description = pkgDesc;

      serviceConfig = {
        DynamicUser = true;

        ExecStart = ''
          ${pkgs.domoticz}/bin/domoticz -noupdates -www ${toString cfg.port} -wwwbind ${cfg.bind} -sslwww 0 -userdata /var/lib/domoticz -approot ${pkgs.domoticz}/share/domoticz/ -pidfile /var/run/domoticz.pid
        '';

        Restart = "always";
        StateDirectory = "domoticz";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

  };

}
