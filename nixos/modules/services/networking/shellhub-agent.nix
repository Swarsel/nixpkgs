{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.shellhub-agent;
in
{
  ###### interface

  options = {

    services.shellhub-agent = {

      enable = mkEnableOption "ShellHub Agent daemon";
      package = mkPackageOption pkgs "shellhub-agent" { };

      keepAliveInterval = mkOption {
        default = 30;

        description = ''
          Determine the interval to send the keep alive message to
          the server. This has a direct impact of the bandwidth
          used by the device.
        '';

        type = types.int;
      };

      preferredHostname = mkOption {
        default = "";

        description = ''
          Set the device preferred hostname. This provides a hint to
          the server to use this as hostname if it is available.
        '';

        type = types.str;
      };

      privateKey = mkOption {
        default = "/var/lib/shellhub-agent/private.key";

        description = ''
          Location where to store the ShellHub Agent private
          key.
        '';

        type = types.path;
      };

      server = mkOption {
        default = "https://cloud.shellhub.io";

        description = ''
          Server address of ShellHub Gateway to connect.
        '';

        type = types.str;
      };

      tenantId = mkOption {
        description = ''
          The tenant ID to use when connecting to the ShellHub
          Gateway.
        '';

        example = "ba0a880c-2ada-11eb-a35e-17266ef329d6";
        type = types.str;
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    systemd.services.shellhub-agent = {
      after = [
        "local-fs.target"
        "network.target"
        "network-online.target"
        "time-sync.target"
      ];

      description = "ShellHub Agent";

      environment = {
        SHELLHUB_KEEPALIVE_INTERVAL = toString cfg.keepAliveInterval;
        SHELLHUB_PREFERRED_HOSTNAME = cfg.preferredHostname;
        SHELLHUB_PRIVATE_KEY = cfg.privateKey;
        SHELLHUB_SERVER_ADDRESS = cfg.server;
        SHELLHUB_TENANT_ID = cfg.tenantId;
      };

      requires = [ "local-fs.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/agent";
        Restart = "on-failure";
        # The service starts sessions for different users.
        User = "root";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
