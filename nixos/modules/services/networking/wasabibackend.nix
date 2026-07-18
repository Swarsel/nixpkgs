{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.wasabibackend;
  opt = options.services.wasabibackend;

  inherit (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    optionalString
    types
    ;

  confOptions = {
    BitcoinRpcConnectionString = "${cfg.rpc.user}:${cfg.rpc.password}";
  }
  // optionalAttrs (cfg.network == "mainnet") {
    MainNetBitcoinCoreRpcEndPoint = "${cfg.rpc.ip}:${toString cfg.rpc.port}";
    MainNetBitcoinP2pEndPoint = "${cfg.endpoint.ip}:${toString cfg.endpoint.port}";
    Network = "Main";
  }
  // optionalAttrs (cfg.network == "testnet") {
    Network = "TestNet";
    TestNetBitcoinCoreRpcEndPoint = "${cfg.rpc.ip}:${toString cfg.rpc.port}";
    TestNetBitcoinP2pEndPoint = "${cfg.endpoint.ip}:${toString cfg.endpoint.port}";
  }
  // optionalAttrs (cfg.network == "regtest") {
    Network = "RegTest";
    RegTestBitcoinCoreRpcEndPoint = "${cfg.rpc.ip}:${toString cfg.rpc.port}";
    RegTestBitcoinP2pEndPoint = "${cfg.endpoint.ip}:${toString cfg.endpoint.port}";
  };

  configFile = pkgs.writeText "wasabibackend.conf" (builtins.toJSON confOptions);

in
{

  options = {

    services.wasabibackend = {
      enable = mkEnableOption "Wasabi backend service";

      customConfigFile = mkOption {
        default = null;
        description = "Defines the path to a custom configuration file that is copied to the user's directory. Overrides any config options.";
        type = types.nullOr types.path;
      };

      dataDir = mkOption {
        default = "/var/lib/wasabibackend";
        description = "The data directory for the Wasabi backend node.";
        type = types.path;
      };

      endpoint = {
        ip = mkOption {
          default = "127.0.0.1";
          description = "IP address for P2P connection to bitcoind.";
          type = types.str;
        };

        port = mkOption {
          default = 8333;
          description = "Port for P2P connection to bitcoind.";
          type = types.port;
        };
      };

      group = mkOption {
        default = cfg.user;
        defaultText = literalExpression "config.${opt.user}";
        description = "The group as which to run the wasabibackend node.";
        type = types.str;
      };

      network = mkOption {
        default = "mainnet";
        description = "The network to use for the Wasabi backend service.";

        type = types.enum [
          "mainnet"
          "testnet"
          "regtest"
        ];
      };

      rpc = {
        ip = mkOption {
          default = "127.0.0.1";
          description = "IP address for RPC connection to bitcoind.";
          type = types.str;
        };

        password = mkOption {
          default = "password";
          description = "RPC password for the bitcoin endpoint. Warning: this is stored in cleartext in the Nix store! Use `configFile` or `passwordFile` if needed.";
          type = types.str;
        };

        passwordFile = mkOption {
          default = null;
          description = "File that contains the password of the RPC user.";
          type = types.nullOr types.path;
        };

        port = mkOption {
          default = 8332;
          description = "Port for RPC connection to bitcoind.";
          type = types.port;
        };

        user = mkOption {
          default = "bitcoin";
          description = "RPC user for the bitcoin endpoint.";
          type = types.str;
        };
      };

      user = mkOption {
        default = "wasabibackend";
        description = "The user as which to run the wasabibackend node.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.wasabibackend = {
      after = [ "network-online.target" ];
      description = "wasabibackend server";

      environment = {
        DOTNET_CLI_TELEMETRY_OPTOUT = "true";
        DOTNET_PRINT_TELEMETRY_MESSAGE = "false";
      };

      preStart = ''
        mkdir -p ${cfg.dataDir}/.walletwasabi/backend
        ${
          if cfg.customConfigFile != null then
            ''
              cp -v ${cfg.customConfigFile} ${cfg.dataDir}/.walletwasabi/backend/Config.json
            ''
          else
            ''
              cp -v ${configFile} ${cfg.dataDir}/.walletwasabi/backend/Config.json
              ${optionalString (cfg.rpc.passwordFile != null) ''
                CONFIGTMP=$(mktemp)
                cat ${cfg.dataDir}/.walletwasabi/backend/Config.json | ${pkgs.jq}/bin/jq --arg rpconnection "${cfg.rpc.user}:$(cat "${cfg.rpc.passwordFile}")" '. + { BitcoinRpcConnectionString: $rpconnection }' > $CONFIGTMP
                mv $CONFIGTMP ${cfg.dataDir}/.walletwasabi/backend/Config.json
              ''}
            ''
        }
        chmod ug+w ${cfg.dataDir}/.walletwasabi/backend/Config.json
      '';

      serviceConfig = {
        ExecStart = "${pkgs.wasabibackend}/bin/WasabiBackend";
        Group = cfg.group;
        ProtectSystem = "full";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0770 '${cfg.user}' '${cfg.group}' - -"
    ];

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      description = "wasabibackend daemon user";
      group = cfg.group;
      home = cfg.dataDir;
      isSystemUser = true;
      name = cfg.user;
    };

  };
}
