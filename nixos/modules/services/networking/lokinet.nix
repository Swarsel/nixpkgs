{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.lokinet;
  dataDir = "/var/lib/lokinet";
  settingsFormat = pkgs.formats.ini { listsAsDuplicateKeys = true; };
  configFile = settingsFormat.generate "lokinet.ini" (
    lib.filterAttrsRecursive (n: v: v != null) cfg.settings
  );
in
with lib;
{
  options.services.lokinet = {
    enable = mkEnableOption "Lokinet daemon";
    package = mkPackageOption pkgs "lokinet" { };

    settings = mkOption {
      default = { };

      description = ''
        Configuration for Lokinet.
        Currently, the best way to view the available settings is by
        generating a config file using `lokinet -g`.
      '';

      example = literalExpression ''
        {
          dns = {
            bind = "127.3.2.1";
            upstream = [ "1.1.1.1" "8.8.8.8" ];
          };

          network.exit-node = [ "example.loki" "example2.loki" ];
        }
      '';

      type =
        with types;
        submodule {
          options = {
            dns = {
              bind = mkOption {
                default = "127.3.2.1";
                description = "Address to bind to for handling DNS requests.";
                type = str;
              };

              upstream = mkOption {
                default = [ "9.9.9.10" ];

                description = ''
                  Upstream resolver(s) to use as fallback for non-loki addresses.
                  Multiple values accepted.
                '';

                example = [
                  "1.1.1.1"
                  "8.8.8.8"
                ];

                type = listOf str;
              };
            };

            network = {
              exit = mkOption {
                default = false;

                description = ''
                  Whether to act as an exit node. Beware that this
                  increases demand on the server and may pose liability concerns.
                  Enable at your own risk.
                '';

                type = bool;
              };

              exit-node = mkOption {
                default = null;

                description = ''
                  Specify a `.loki` address and an optional ip range to use as an exit broker.
                  See <http://probably.loki/wiki/index.php?title=Exit_Nodes> for
                  a list of exit nodes.
                '';

                example = ''
                  exit-node = [ "example.loki" ];              # maps all exit traffic to example.loki
                  exit-node = [ "example.loki:100.0.0.0/24" ]; # maps 100.0.0.0/24 to example.loki
                '';

                type = nullOr (listOf str);
              };

              keyfile = mkOption {
                default = null;

                description = ''
                  The private key to persist address with. If not specified the address will be ephemeral.
                  This keyfile is generated automatically if the specified file doesn't exist.
                '';

                example = "snappkey.private";
                type = nullOr str;
              };
            };
          };

          freeformType = settingsFormat.type;
        };
    };

    useLocally = mkOption {
      default = false;
      description = "Whether to use Lokinet locally.";
      example = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.resolvconf.extraConfig = mkIf cfg.useLocally ''
      name_servers="${cfg.settings.dns.bind}"
    '';

    systemd.services.lokinet = {
      after = [
        "network-online.target"
        "network.target"
      ];

      description = "Lokinet";

      preStart = ''
        ln -sf ${cfg.package}/share/bootstrap.signed ${dataDir}
        ${pkgs.coreutils}/bin/install -m 600 ${configFile} ${dataDir}/lokinet.ini

        ${optionalString (cfg.settings.network.keyfile != null) ''
          ${pkgs.crudini}/bin/crudini --set ${dataDir}/lokinet.ini network keyfile "${dataDir}/${cfg.settings.network.keyfile}"
        ''}
      '';

      serviceConfig = {
        AmbientCapabilities = [
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
        ];

        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/lokinet ${dataDir}/lokinet.ini";
        # hardening
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadWritePaths = "/dev/net/tun";
        Restart = "always";
        RestartSec = "5s";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "lokinet";
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
        "network.target"
      ];
    };
  };
}
