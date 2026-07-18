{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dante;
  confFile = pkgs.writeText "dante-sockd.conf" ''
    user.privileged: root
    user.unprivileged: dante
    logoutput: syslog

    ${cfg.config}
  '';
in

{
  options = {
    services.dante = {
      config = lib.mkOption {
        description = ''
          Contents of Dante's configuration file.
          NOTE: user.privileged, user.unprivileged and logoutput are set by the service.
        '';

        type = lib.types.lines;
      };

      enable = lib.mkEnableOption "Dante SOCKS proxy";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.config != "";
        message = "please provide Dante configuration file contents";
      }
    ];

    systemd.services.dante = {
      after = [ "network-online.target" ];
      description = "Dante SOCKS v4 and v5 compatible proxy server";

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${pkgs.dante}/bin/sockd -f ${confFile}";
        # Can crash sometimes; see https://github.com/NixOS/nixpkgs/pull/39005#issuecomment-381828708
        Restart = "on-failure";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups.dante = { };

    users.users.dante = {
      description = "Dante SOCKS proxy daemon user";
      group = "dante";
      isSystemUser = true;
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ arobyn ];
  };
}
