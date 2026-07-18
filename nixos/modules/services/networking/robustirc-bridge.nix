{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.robustirc-bridge;
in
{
  options = {
    services.robustirc-bridge = {
      enable = mkEnableOption "RobustIRC bridge";

      extraFlags = mkOption {
        default = [ ];
        description = "Extra flags passed to the {command}`robustirc-bridge` command. See [RobustIRC Documentation](https://robustirc.net/docs/adminguide.html#_bridge) or {manpage}`robustirc-bridge(1)` for details.";

        example = [
          "-network robustirc.net"
        ];

        type = types.listOf types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.robustirc-bridge = {
      after = [ "network.target" ];
      description = "RobustIRC bridge";

      documentation = [
        "man:robustirc-bridge(1)"
        "https://robustirc.net/"
      ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.robustirc-bridge}/bin/robustirc-bridge ${concatStringsSep " " cfg.extraFlags}";
        # Hardening
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = true;
        Restart = "on-failure";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
