{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.do-agent;

in
{
  options.services.do-agent = {
    enable = lib.mkEnableOption "do-agent, the DigitalOcean droplet metrics agent";
  };

  config = lib.mkIf cfg.enable {
    systemd.packages = [ pkgs.do-agent ];

    systemd.services.do-agent = {
      serviceConfig = {
        DynamicUser = true;

        ExecStart = [
          ""
          "${pkgs.do-agent}/bin/do-agent --syslog"
        ];
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
