{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.convos;
in
{
  options.services.convos = {
    enable = mkEnableOption "Convos";

    listenAddress = mkOption {
      default = "*";
      description = "Address or host the web interface should listen on";
      example = "127.0.0.1";
      type = types.str;
    };

    listenPort = mkOption {
      default = 3000;
      description = "Port the web interface should listen on";
      example = 8080;
      type = types.port;
    };

    reverseProxy = mkOption {
      default = false;

      description = ''
        Enables reverse proxy support. This will allow Convos to automatically
        pick up the `X-Forwarded-For` and
        `X-Request-Base` HTTP headers set in your reverse proxy
        web server. Note that enabling this option without a reverse proxy in
        front will be a security issue.
      '';

      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.convos = {
      after = [ "network.target" ];
      description = "Convos Service";

      environment = {
        CONVOS_HOME = "%S/convos";
        CONVOS_REVERSE_PROXY = if cfg.reverseProxy then "1" else "0";
        MOJO_LISTEN = "http://${toString cfg.listenAddress}:${toString cfg.listenPort}";
      };

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = "${pkgs.convos}/bin/convos daemon";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "convos";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        WorkingDirectory = "%S/convos";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
