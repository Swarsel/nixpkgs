{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  eachBitcoind = filterAttrs (bitcoindName: cfg: cfg.enable) config.services.bitcoind;

  rpcUserOpts =
    { name, ... }:
    {
      options = {
        name = mkOption {
          description = ''
            Username for JSON-RPC connections.
          '';

          example = "alice";
          type = types.str;
        };

        passwordHMAC = mkOption {
          description = ''
            Password HMAC-SHA-256 for JSON-RPC connections. Must be a string of the
            format \<SALT-HEX\>$\<HMAC-HEX\>.

            Tool (Python script) for HMAC generation is available here:
            <https://github.com/bitcoin/bitcoin/blob/master/share/rpcauth/rpcauth.py>
          '';

          example = "f7efda5c189b999524f151318c0c86$d5b51b3beffbc02b724e5d095828e0bc8b2456e9ac8757ae3211a5d9b16a22ae";
          type = types.uniq (types.strMatching "[0-9a-f]+\\$[0-9a-f]{64}");
        };
      };

      config = {
        name = mkDefault name;
      };
    };

  bitcoindOpts =
    {
      config,
      lib,
      name,
      ...
    }:
    {
      options = {

        enable = mkEnableOption "Bitcoin daemon";
        package = mkPackageOption pkgs "bitcoind" { };

        configFile = mkOption {
          default = null;
          description = "The configuration file path to supply bitcoind.";
          example = "/var/lib/${name}/bitcoin.conf";
          type = types.nullOr types.path;
        };

        dataDir = mkOption {
          default = "/var/lib/bitcoind-${name}";
          description = "The data directory for bitcoind.";
          type = types.path;
        };

        dbCache = mkOption {
          default = null;
          description = "Override the default database cache size in MiB.";
          example = 4000;
          type = types.nullOr (types.ints.between 4 16384);
        };

        extraCmdlineOptions = mkOption {
          default = [ ];

          description = ''
            Extra command line options to pass to bitcoind.
            Run bitcoind --help to list all available options.
          '';

          type = types.listOf types.str;
        };

        extraConfig = mkOption {
          default = "";
          description = "Additional configurations to be appended to {file}`bitcoin.conf`.";

          example = ''
            par=16
            rpcthreads=16
            logips=1
          '';

          type = types.lines;
        };

        group = mkOption {
          default = config.user;
          description = "The group as which to run bitcoind.";
          type = types.str;
        };

        pidFile = mkOption {
          default = "${config.dataDir}/bitcoind.pid";
          description = "Location of bitcoind pid file.";
          type = types.path;
        };

        port = mkOption {
          default = null;
          description = "Override the default port on which to listen for connections.";
          type = types.nullOr types.port;
        };

        prune = mkOption {
          default = null;

          description = ''
            Reduce storage requirements by enabling pruning (deleting) of old
            blocks. This allows the pruneblockchain RPC to be called to delete
            specific blocks, and enables automatic pruning of old blocks if a
            target size in MiB is provided. This mode is incompatible with -txindex
            and -rescan. Warning: Reverting this setting requires re-downloading
            the entire blockchain. ("disable" = disable pruning blocks, "manual"
            = allow manual pruning via RPC, >=550 = automatically prune block files
            to stay under the specified target size in MiB).
          '';

          example = 10000;

          type = types.nullOr (
            types.coercedTo (types.enum [
              "disable"
              "manual"
            ]) (x: if x == "disable" then 0 else 1) types.ints.unsigned
          );
        };

        rpc = {
          port = mkOption {
            default = null;
            description = "Override the default port on which to listen for JSON-RPC connections.";
            type = types.nullOr types.port;
          };

          users = mkOption {
            default = { };
            description = "RPC user information for JSON-RPC connections.";

            example = literalExpression ''
              {
                alice.passwordHMAC = "f7efda5c189b999524f151318c0c86$d5b51b3beffbc02b724e5d095828e0bc8b2456e9ac8757ae3211a5d9b16a22ae";
                bob.passwordHMAC = "b2dd077cb54591a2f3139e69a897ac$4e71f08d48b4347cf8eff3815c0e25ae2e9a4340474079f55705f40574f4ec99";
              }
            '';

            type = types.attrsOf (types.submodule rpcUserOpts);
          };
        };

        testnet = mkOption {
          default = false;
          description = "Whether to use the testnet instead of mainnet.";
          type = types.bool;
        };

        user = mkOption {
          default = "bitcoind-${name}";
          description = "The user as which to run bitcoind.";
          type = types.str;
        };
      };
    };
in
{

  options = {
    services.bitcoind = mkOption {
      default = { };
      description = "Specification of one or more bitcoind instances.";
      type = types.attrsOf (types.submodule bitcoindOpts);
    };
  };

  config = mkIf (eachBitcoind != { }) {

    assertions = flatten (
      mapAttrsToList (bitcoindName: cfg: [
        {
          assertion =
            (cfg.prune != null)
            -> (
              builtins.elem cfg.prune [
                "disable"
                "manual"
                0
                1
              ]
              || (builtins.isInt cfg.prune && cfg.prune >= 550)
            );

          message = ''
            If set, services.bitcoind.${bitcoindName}.prune has to be "disable", "manual", 0 , 1 or >= 550.
          '';
        }
        {
          assertion = (cfg.rpc.users != { }) -> (cfg.configFile == null);

          message = ''
            You cannot set both services.bitcoind.${bitcoindName}.rpc.users and services.bitcoind.${bitcoindName}.configFile
            as they are exclusive. RPC user setting would have no effect if custom configFile would be used.
          '';
        }
      ]) eachBitcoind
    );

    environment.systemPackages = flatten (
      mapAttrsToList (bitcoindName: cfg: [
        cfg.package
      ]) eachBitcoind
    );

    systemd.services = mapAttrs' (
      bitcoindName: cfg:
      (nameValuePair "bitcoind-${bitcoindName}" (
        let
          configFile = pkgs.writeText "bitcoin.conf" ''
            # If Testnet is enabled, we need to add [test] section
            # otherwise, some options (e.g.: custom RPC port) will not work
            ${optionalString cfg.testnet "[test]"}
            # RPC users
            ${concatMapStringsSep "\n" (rpcUser: "rpcauth=${rpcUser.name}:${rpcUser.passwordHMAC}") (
              attrValues cfg.rpc.users
            )}
            # Extra config options (from bitcoind nixos service)
            ${cfg.extraConfig}
          '';
        in
        {
          after = [ "network-online.target" ];
          description = "Bitcoin daemon";

          serviceConfig = {
            ExecStart = ''
              ${cfg.package}/bin/bitcoind \
              ${if (cfg.configFile != null) then "-conf=${cfg.configFile}" else "-conf=${configFile}"} \
              -datadir=${cfg.dataDir} \
              -pid=${cfg.pidFile} \
              ${optionalString cfg.testnet "-testnet"}\
              ${optionalString (cfg.port != null) "-port=${toString cfg.port}"}\
              ${optionalString (cfg.prune != null) "-prune=${toString cfg.prune}"}\
              ${optionalString (cfg.dbCache != null) "-dbcache=${toString cfg.dbCache}"}\
              ${optionalString (cfg.rpc.port != null) "-rpcport=${toString cfg.rpc.port}"}\
              ${toString cfg.extraCmdlineOptions}
            '';

            Group = cfg.group;
            MemoryDenyWriteExecute = "true";
            NoNewPrivileges = "true";
            PrivateDevices = "true";
            # Hardening measures
            PrivateTmp = "true";
            ProtectSystem = "full";
            Restart = "on-failure";
            User = cfg.user;
          };

          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
        }
      ))
    ) eachBitcoind;

    systemd.tmpfiles.rules = flatten (
      mapAttrsToList (bitcoindName: cfg: [
        "d '${cfg.dataDir}' 0770 '${cfg.user}' '${cfg.group}' - -"
      ]) eachBitcoind
    );

    users.groups = mapAttrs' (bitcoindName: cfg: (nameValuePair "${cfg.group}" { })) eachBitcoind;

    users.users = mapAttrs' (
      bitcoindName: cfg:
      (nameValuePair "bitcoind-${bitcoindName}" {
        description = "Bitcoin daemon user";
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
        name = cfg.user;
      })
    ) eachBitcoind;

  };

  meta.maintainers = with maintainers; [ _1000101 ];

}
