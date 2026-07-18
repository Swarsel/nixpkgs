{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gobgpd;
  format = pkgs.formats.toml { };
  confFile = format.generate "gobgpd.conf" cfg.settings;
in
{
  options.services.gobgpd = {
    enable = lib.mkEnableOption "GoBGP Routing Daemon";

    settings = lib.mkOption {
      default = { };

      description = ''
        GoBGP configuration. Refer to
        <https://github.com/osrg/gobgp#documentation>
        for details on supported values.
      '';

      example = lib.literalExpression ''
        {
          global = {
            config = {
              as = 64512;
              router-id = "192.168.255.1";
            };
          };
          neighbors = [
            {
              config = {
                neighbor-address = "10.0.255.1";
                peer-as = 65001;
              };
            }
            {
              config = {
                neighbor-address = "10.0.255.2";
                peer-as = 65002;
              };
            }
          ];
        }
      '';

      type = format.type;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.gobgpd ];

    systemd.services.gobgpd = {
      after = [ "network.target" ];
      description = "GoBGP Routing Daemon";

      serviceConfig = {
        AmbientCapabilities = "cap_net_bind_service";
        DynamicUser = true;
        ExecReload = "${pkgs.gobgpd}/bin/gobgpd -r";
        ExecStart = "${pkgs.gobgpd}/bin/gobgpd -f ${confFile} --sdnotify";
        ExecStartPre = "${pkgs.gobgpd}/bin/gobgpd -f ${confFile} -d";
        Type = "notify";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
