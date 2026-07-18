{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    types
    ;

  cfg = config.services.meme-bingo-web;
in
{
  options = {
    services.meme-bingo-web = {
      enable = mkEnableOption ''
        a web app for the meme bingo, rendered entirely on the web server and made interactive with forms.

        Note: The application's author suppose to run meme-bingo-web behind a reverse proxy for SSL and HTTP/3
      '';

      package = mkPackageOption pkgs "meme-bingo-web" { };

      address = mkOption {
        default = "localhost";

        description = ''
          The address the webserver will bind to.
        '';

        example = "::";
        type = types.str;
      };

      baseUrl = mkOption {
        default = "http://localhost:41678/";

        description = ''
          URL to be used for the HTML \<base\> element on all HTML routes.
        '';

        example = "https://bingo.example.com/";
        type = types.str;
      };

      openFirewall = mkEnableOption ''
        Opens the specified port in the firewall.
      '';

      port = mkOption {
        default = 41678;

        description = ''
          Port to be used for the web server.
        '';

        example = 21035;
        type = types.port;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.meme-bingo-web = {
      description = "A web app for playing meme bingos";

      environment = {
        MEME_BINGO_ADDRESS = cfg.address;
        MEME_BINGO_BASE = cfg.baseUrl;
        MEME_BINGO_PORT = toString cfg.port;
      };

      path = [ cfg.package ];

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "/dev/random" ];
        DynamicUser = true;
        ExecPaths = [ "/nix/store" ];
        ExecStart = "${cfg.package}/bin/meme-bingo-web";
        Group = "meme-bingo-web";

        InaccessiblePaths = [
          "/dev/shm"
          "/sys"
          "/run/dbus"
          "/run/user"
          "/run/nscd"
        ];

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoExecPaths = [ "/" ];
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "always";
        RestartSec = 1;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictFilesystems = [
          "@basic-api"
          "~sysfs"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
        User = "meme-bingo-web";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
