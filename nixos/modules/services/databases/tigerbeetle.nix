{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.tigerbeetle;
in
{
  options = {
    services.tigerbeetle = with lib; {
      enable = mkEnableOption "TigerBeetle server";
      package = mkPackageOption pkgs "tigerbeetle" { };

      addresses = mkOption {
        default = [ "3001" ];

        description = ''
          The addresses of all replicas in the cluster.
          This should be a list of IPv4/IPv6 addresses with port numbers.
          Either the address or port number (but not both) may be omitted, in which case a default of 127.0.0.1 or 3001 will be used.
          The first address in the list corresponds to the address for replica 0, the second address for replica 1, and so on.
        '';

        type = types.listOf types.nonEmptyStr;
      };

      cacheGridSize = mkOption {
        default = "1GiB";

        description = ''
          The grid cache size.
          The grid cache acts like a page cache for TigerBeetle.
          It is recommended to set this as large as possible.
        '';

        type = types.strMatching "[0-9]+(K|M|G)iB";
      };

      clusterId = mkOption {
        default = 0;

        description = ''
          The 128-bit cluster ID used to create the replica data file (if needed).
          Since Nix only supports integers up to 64 bits, you need to pass a string to this if the cluster ID can't fit in 64 bits.
          Otherwise, you can pass the cluster ID as either an integer or a string.
        '';

        type = types.either types.ints.unsigned (types.strMatching "[0-9]+");
      };

      replicaCount = mkOption {
        default = 1;

        description = ''
          The number of replicas participating in replication of the cluster.
        '';

        type = types.ints.unsigned;
      };

      replicaIndex = mkOption {
        default = 0;

        description = ''
          The index (starting at 0) of the replica in the cluster.
        '';

        type = types.ints.unsigned;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      let
        numAddresses = builtins.length cfg.addresses;
      in
      [
        {
          assertion = cfg.replicaIndex < cfg.replicaCount;
          message = "the TigerBeetle replica index must fit the configured replica count";
        }
        {
          assertion = cfg.replicaCount == numAddresses;

          message =
            if cfg.replicaCount < numAddresses then
              "TigerBeetle must not have more addresses than the configured number of replicas"
            else
              "TigerBeetle must be configured with the addresses of all replicas";
        }
      ];

    environment.systemPackages = [ cfg.package ];

    systemd.services.tigerbeetle =
      let
        replicaDataPath = "/var/lib/tigerbeetle/${toString cfg.clusterId}_${toString cfg.replicaIndex}.tigerbeetle";
      in
      {
        after = [ "network.target" ];
        description = "TigerBeetle server";

        preStart = ''
          if ! test -e "${replicaDataPath}"; then
            ${lib.getExe cfg.package} format --cluster="${toString cfg.clusterId}" --replica="${toString cfg.replicaIndex}" --replica-count="${toString cfg.replicaCount}" "${replicaDataPath}"
          fi
        '';

        serviceConfig = {
          DevicePolicy = "closed";
          DynamicUser = true;
          ExecStart = "${lib.getExe cfg.package} start --cache-grid=${cfg.cacheGridSize} --addresses=${lib.escapeShellArg (builtins.concatStringsSep "," cfg.addresses)} ${replicaDataPath}";
          LockPersonality = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "noaccess";
          ProtectSystem = "strict";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          StateDirectory = "tigerbeetle";
          StateDirectoryMode = 700;
          Type = "exec";
        };

        wantedBy = [ "multi-user.target" ];
      };
  };

  meta = {
    buildDocsInSandbox = true;
    doc = ./tigerbeetle.md;
    maintainers = with lib.maintainers; [ danielsidhion ];
  };
}
