{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.local-content-share;
in
{
  options.services.local-content-share = {
    enable = lib.mkEnableOption "Local-Content-Share";
    package = lib.mkPackageOption pkgs "local-content-share" { };

    listenAddress = lib.mkOption {
      default = "";

      description = ''
        Address on which the service will be available.

        The service will listen on all interfaces if set to an empty string.
      '';

      example = "127.0.0.1";
      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether to automatically open the specified port in the firewall";
      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 8080;
      description = "Port on which the service will be available";
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.local-content-share = {
      after = [ "network.target" ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${lib.getExe' cfg.package "local-content-share"} -listen=${cfg.listenAddress}:${toString cfg.port}";
        Restart = "on-failure";
        StateDirectory = "local-content-share";
        StateDirectoryMode = "0700";
        Type = "simple";
        User = "local-content-share";
        WorkingDirectory = "/var/lib/local-content-share";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ e-v-o-l-v-e ];
}
