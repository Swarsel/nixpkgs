{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.ergo;
  opt = options.services.ergo;

  inherit (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    optionalString
    types
    ;

  configFile = pkgs.writeText "ergo.conf" (
    ''
      ergo {
        directory = "${cfg.dataDir}"
        node {
          mining = false
        }
        wallet.secretStorage.secretDir = "${cfg.dataDir}/wallet/keystore"
      }

      scorex {
        network {
          bindAddress = "${cfg.listen.ip}:${toString cfg.listen.port}"
        }
    ''
    + optionalString (cfg.api.keyHash != null) ''
      restApi {
         apiKeyHash = "${cfg.api.keyHash}"
         bindAddress = "${cfg.api.listen.ip}:${toString cfg.api.listen.port}"
      }
    ''
    + ''
      }
    ''
  );

in
{

  options = {

    services.ergo = {
      enable = mkEnableOption "Ergo service";

      api = {
        keyHash = mkOption {
          default = null;
          description = "Hex-encoded Blake2b256 hash of an API key as a 64-chars long Base16 string.";
          example = "324dcf027dd4a30a932c441f365a25e86b173defa4b8e58948253471b81b72cf";
          type = types.nullOr types.str;
        };

        listen = {
          ip = mkOption {
            default = "0.0.0.0";
            description = "IP address that the Ergo node API should listen on if {option}`api.keyHash` is defined.";
            type = types.str;
          };

          port = mkOption {
            default = 9052;
            description = "Listen port for the API endpoint if {option}`api.keyHash` is defined.";
            type = types.port;
          };
        };
      };

      dataDir = mkOption {
        default = "/var/lib/ergo";
        description = "The data directory for the Ergo node.";
        type = types.path;
      };

      group = mkOption {
        default = cfg.user;
        defaultText = literalExpression "config.${opt.user}";
        description = "The group as which to run the Ergo node.";
        type = types.str;
      };

      listen = {
        ip = mkOption {
          default = "0.0.0.0";
          description = "IP address on which the Ergo node should listen.";
          type = types.str;
        };

        port = mkOption {
          default = 9006;
          description = "Listen port for the Ergo node.";
          type = types.port;
        };
      };

      openFirewall = mkOption {
        default = false;
        description = "Open ports in the firewall for the Ergo node as well as the API.";
        type = types.bool;
      };

      testnet = mkOption {
        default = false;
        description = "Connect to testnet network instead of the default mainnet.";
        type = types.bool;
      };

      user = mkOption {
        default = "ergo";
        description = "The user as which to run the Ergo node.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listen.port ] ++ [ cfg.api.listen.port ];
    };

    systemd.services.ergo = {
      after = [ "network-online.target" ];
      description = "ergo server";

      serviceConfig = {
        ExecStart = ''
          ${pkgs.ergo}/bin/ergo \
                                ${optionalString (!cfg.testnet) "--mainnet"} \
                                -c ${configFile}'';

        Group = cfg.group;
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
      description = "Ergo daemon user";
      group = cfg.group;
      home = cfg.dataDir;
      isSystemUser = true;
      name = cfg.user;
    };

  };
}
