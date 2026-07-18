{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe'
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.firezone.gui-client;
in
{
  options = {
    services.firezone.gui-client = {
      enable = mkEnableOption "the firezone gui client";
      package = mkPackageOption pkgs "firezone-gui-client" { };

      allowedUsers = mkOption {
        default = [ ];

        description = ''
          All listed users will become part of the `firezone-client` group so
          they can control the tunnel service. This is a convenience option.
        '';

        type = types.listOf types.str;
      };

      logLevel = mkOption {
        default = "info";

        description = ''
          The log level for the firezone application. See
          [RUST_LOG](https://docs.rs/env_logger/latest/env_logger/#enabling-logging)
          for the format.
        '';

        type = types.str;
      };

      name = mkOption {
        description = "The name of this client as shown in firezone";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    # Required for deep-link mimetype registration
    environment.systemPackages = [ cfg.package ];
    # Required for the token store in the gui application
    services.gnome.gnome-keyring.enable = true;

    systemd.services.firezone-tunnel-service = {
      after = [ "network.target" ];
      description = "GUI tunnel service for the Firezone zero-trust access platform";

      environment = {
        FIREZONE_NAME = cfg.name;
        LOG_DIR = "%L/dev.firezone.client";
        RUST_LOG = cfg.logLevel;
      };

      path = [ pkgs.util-linux ];

      script = ''
        # If FIREZONE_ID is not given by the user, use a persisted (or newly generated) uuid.
        if [[ -z "''${FIREZONE_ID:-}" ]]; then
          if [[ ! -e client_id ]]; then
            uuidgen -r > client_id
          fi
          export FIREZONE_ID=$(< client_id)
        fi

        exec ${getExe' cfg.package "firezone-client-tunnel"} run
      '';

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_ADMIN" ];
        CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
        DeviceAllow = "/dev/net/tun";
        # This block contains hardcoded values in the client, we cannot change these :(
        Group = "firezone-client";
        LockPersonality = true;
        LogsDirectory = "dev.firezone.client";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = false;
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
        Restart = "on-failure";
        RestartSec = 10;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "dev.firezone.client";
        StateDirectory = "dev.firezone.client";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        Type = "notify";
        UMask = "077";
        WorkingDirectory = "/var/lib/dev.firezone.client";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.firezone-client.members = cfg.allowedUsers;
  };

  meta.maintainers = with lib.maintainers; [
    oddlama
    patrickdag
  ];
}
