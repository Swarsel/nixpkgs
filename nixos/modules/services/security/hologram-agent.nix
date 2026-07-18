{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hologram-agent;

  cfgFile = pkgs.writeText "hologram-agent.json" (
    builtins.toJSON {
      host = cfg.dialAddress;
    }
  );
in
{
  options = {
    services.hologram-agent = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the Hologram agent for AWS instance credentials";
        type = lib.types.bool;
      };

      dialAddress = lib.mkOption {
        default = "localhost:3100";
        description = "Hologram server and port.";
        type = lib.types.str;
      };

      httpPort = lib.mkOption {
        default = "80";
        description = "Port for metadata service to listen on.";
        type = lib.types.str;
      };

    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "dummy" ];

    networking.interfaces.dummy0.ipv4.addresses = [
      {
        address = "169.254.169.254";
        prefixLength = 32;
      }
    ];

    systemd.services.hologram-agent = {
      after = [ "network.target" ];
      description = "Provide EC2 instance credentials to machines outside of EC2";

      preStart = ''
        /run/current-system/sw/bin/rm -fv /run/hologram.sock
      '';

      requires = [
        "network-link-dummy0.service"
        "network-addresses-dummy0.service"
      ];

      serviceConfig = {
        ExecStart = "${pkgs.hologram}/bin/hologram-agent -debug -conf ${cfgFile} -port ${cfg.httpPort}";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

  meta.maintainers = [ ];
}
