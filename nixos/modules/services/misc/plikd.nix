{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.plikd;

  format = pkgs.formats.toml { };
  plikdCfg = format.generate "plikd.cfg" cfg.settings;
in
{
  options = {
    services.plikd = {
      enable = lib.mkEnableOption "plikd, a temporary file upload system";

      openFirewall = lib.mkOption {
        default = false;
        description = "Open ports in the firewall for the plikd.";
        type = lib.types.bool;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Configuration for plikd, see <https://github.com/root-gg/plik/blob/master/server/plikd.cfg>
          for supported values.
        '';

        type = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.ListenPort ];
    };

    services.plikd.settings = lib.mapAttrs (name: lib.mkDefault) {
      DataBackend = "file";

      DataBackendConfig = {
        Directory = "/var/lib/plikd";
      };

      ListenAddress = "localhost";
      ListenPort = 8080;

      MetadataBackendConfig = {
        ConnectionString = "/var/lib/plikd/plik.db";
        Driver = "sqlite3";
      };
    };

    systemd.services.plikd = {
      after = [ "network.target" ];
      description = "Plikd file sharing server";

      serviceConfig = {
        DevicePolicy = "closed";
        DynamicUser = true;
        ExecStart = "${pkgs.plikd}/bin/plikd --config ${plikdCfg}";
        LockPersonality = "yes";
        LogsDirectory = "plikd";
        MemoryDenyWriteExecute = "yes";
        # Basic hardening
        NoNewPrivileges = "yes";
        PrivateDevices = "yes";
        PrivateTmp = "yes";
        ProtectControlGroups = "yes";
        ProtectHome = "read-only";
        ProtectKernelModules = "yes";
        ProtectKernelTunables = "yes";
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
        RestrictNamespaces = "yes";
        RestrictRealtime = "yes";
        RestrictSUIDSGID = "yes";
        StateDirectory = "plikd";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
