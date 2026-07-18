{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.irkerd;
  ports = [ 6659 ];
in
{
  options.services.irkerd = {
    enable = lib.mkOption {
      default = false;
      description = "Whether to enable irker, an IRC notification daemon.";
      type = lib.types.bool;
    };

    listenAddress = lib.mkOption {
      default = "localhost";

      description = ''
        Specifies the bind address on which the irker daemon listens.
        The default is localhost.

        Irker authors strongly warn about the risks of running this on
        a publicly accessible interface, so change this with caution.
      '';

      example = "0.0.0.0";
      type = lib.types.str;
    };

    nick = lib.mkOption {
      default = "irker";
      description = "Nick to use for irker";
      type = lib.types.str;
    };

    openPorts = lib.mkOption {
      default = false;
      description = "Open ports in the firewall for irkerd";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.irker ];
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openPorts ports;
    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openPorts ports;

    systemd.services.irkerd = {
      after = [ "network.target" ];
      description = "Internet Relay Chat (IRC) notification daemon";

      documentation = [
        "man:irkerd(8)"
        "man:irkerhook(1)"
        "man:irk(1)"
      ];

      serviceConfig = {
        ExecStart = "${pkgs.irker}/bin/irkerd -H ${cfg.listenAddress} -n ${cfg.nick}";
        User = "irkerd";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.irkerd = { };

    users.users.irkerd = {
      description = "Irker daemon user";
      group = "irkerd";
      isSystemUser = true;
    };
  };
}
