{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dgraph;
  settingsFormat = pkgs.formats.json { };
  configFile = settingsFormat.generate "config.json" cfg.settings;
  dgraphWithNode =
    pkgs.runCommand "dgraph"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      }
      ''
        mkdir -p $out/bin
        makeWrapper ${cfg.package}/bin/dgraph $out/bin/dgraph \
          --prefix PATH : "${lib.makeBinPath [ pkgs.nodejs ]}"
      '';
  securityOptions = {
    AmbientCapabilities = "";
    CapabilityBoundingSet = "";
    DeviceAllow = "";
    LockPersonality = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateTmp = true;
    PrivateUsers = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    RemoveIPC = true;

    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
    ];

    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    SystemCallErrorNumber = "EPERM";

    SystemCallFilter = [
      "@system-service"
      "~@cpu-emulation"
      "~@debug"
      "~@keyring"
      "~@memlock"
      "~@obsolete"
      "~@privileged"
      "~@setuid"
    ];
  };
in
{
  options = {
    services.dgraph = {
      enable = lib.mkEnableOption "Dgraph native GraphQL database with a graph backend";
      package = lib.mkPackageOption pkgs "dgraph" { };

      alpha = {
        host = lib.mkOption {
          default = "localhost";

          description = ''
            The host which dgraph alpha will be run on.
          '';

          type = lib.types.str;
        };

        port = lib.mkOption {
          default = 7080;

          description = ''
            The port which to run dgraph alpha on.
          '';

          type = lib.types.port;
        };

      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Contents of the dgraph config. For more details see <https://dgraph.io/docs/deploy/config>
        '';

        type = settingsFormat.type;
      };

      zero = {
        host = lib.mkOption {
          default = "localhost";

          description = ''
            The host which dgraph zero will be run on.
          '';

          type = lib.types.str;
        };

        port = lib.mkOption {
          default = 5080;

          description = ''
            The port which to run dgraph zero on.
          '';

          type = lib.types.port;
        };
      };

    };
  };

  config = lib.mkIf cfg.enable {
    services.dgraph.settings = {
      badger.compression = lib.mkDefault "zstd:3";
    };

    systemd.services.dgraph-alpha = {
      after = [
        "network.target"
        "dgraph-zero.service"
      ];

      description = "Dgraph native GraphQL database with a graph backend. Alpha serves data";
      requires = [ "dgraph-zero.service" ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${dgraphWithNode}/bin/dgraph alpha --config ${configFile} --my ${cfg.alpha.host}:${toString cfg.alpha.port} --zero ${cfg.zero.host}:${toString cfg.zero.port}";

        ExecStop = ''
          ${pkgs.curl}/bin/curl --data "mutation { shutdown { response { message code } } }" \
              --header 'Content-Type: application/graphql' \
              -X POST \
              http://localhost:8080/admin
        '';

        Restart = "on-failure";
        StateDirectory = "dgraph-alpha";
        WorkingDirectory = "/var/lib/dgraph-alpha";
      }
      // securityOptions;

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.dgraph-zero = {
      after = [ "network.target" ];
      description = "Dgraph native GraphQL database with a graph backend. Zero controls node clustering";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/dgraph zero --my ${cfg.zero.host}:${toString cfg.zero.port}";
        Restart = "on-failure";
        StateDirectory = "dgraph-zero";
        WorkingDirectory = "/var/lib/dgraph-zero";
      }
      // securityOptions;

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ happysalada ];
}
