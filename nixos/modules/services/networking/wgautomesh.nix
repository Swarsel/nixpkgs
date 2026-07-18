{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.wgautomesh;
  settingsFormat = pkgs.formats.toml { };
  configFile =
    # Have to remove nulls manually as TOML generator will not just skip key
    # if value is null
    settingsFormat.generate "wgautomesh-config.toml" (
      filterAttrs (k: v: v != null) (
        mapAttrs (k: v: if k == "peers" then map (e: filterAttrs (k: v: v != null) e) v else v) cfg.settings
      )
    );
  runtimeConfigFile =
    if cfg.enableGossipEncryption then "/run/wgautomesh/wgautomesh.toml" else configFile;
in
{
  options.services.wgautomesh = {
    enable = mkEnableOption "the wgautomesh daemon";

    enableGossipEncryption = mkOption {
      default = true;
      description = "Enable encryption of gossip traffic.";
      type = types.bool;
    };

    enablePersistence = mkOption {
      default = true;
      description = "Enable persistence of Wireguard peer info between restarts.";
      type = types.bool;
    };

    gossipSecretFile = mkOption {
      description = ''
        File containing the gossip secret, a shared secret key to use for gossip
        encryption.  Required if `enableGossipEncryption` is set.  This file
        may contain any arbitrary-length utf8 string.  To generate a new gossip
        secret, use a command such as `openssl rand -base64 32`.
      '';

      type = types.path;
    };

    logLevel = mkOption {
      default = "info";
      description = "wgautomesh log level.";

      type = types.enum [
        "trace"
        "debug"
        "info"
        "warn"
        "error"
      ];
    };

    openFirewall = mkOption {
      default = true;
      description = "Automatically open gossip port in firewall (recommended).";
      type = types.bool;
    };

    settings = mkOption {
      default = { };
      description = "Configuration for wgautomesh.";

      type = types.submodule {
        options = {

          gossip_port = mkOption {
            default = 1666;

            description = ''
              wgautomesh gossip port, this MUST be the same number on all nodes in
              the wgautomesh network.
            '';

            type = types.port;
          };

          interface = mkOption {
            description = ''
              Wireguard interface to manage (it is NOT created by wgautomesh, you
              should use another NixOS option to create it such as
              `networking.wireguard.interfaces.wg0 = {...};`).
            '';

            example = "wg0";
            type = types.str;
          };

          lan_discovery = mkOption {
            default = true;
            description = "Enable discovery of peers on the same LAN using UDP broadcast.";
            type = types.bool;
          };

          peers = mkOption {
            default = [ ];
            description = "wgautomesh peer list.";

            type = types.listOf (
              types.submodule {
                options = {
                  address = mkOption {
                    description = ''
                      Wireguard address of this peer (a single IP address, multiple
                      addresses or address ranges are not supported).
                    '';

                    example = "10.0.0.42";
                    type = types.str;
                  };

                  endpoint = mkOption {
                    default = null;

                    description = ''
                      Bootstrap endpoint for connecting to this Wireguard peer if no
                      other address is known or none are working.
                    '';

                    example = "wgnode.mydomain.example:51820";
                    type = types.nullOr types.str;
                  };

                  pubkey = mkOption {
                    description = "Wireguard public key of this peer.";
                    type = types.str;
                  };
                };
              }
            );
          };

          upnp_forward_external_port = mkOption {
            default = null;

            description = ''
              Public port number to try to redirect to this machine's Wireguard
              daemon using UPnP IGD.
            '';

            type = types.nullOr types.port;
          };
        };

        freeformType = settingsFormat.type;

      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [ cfg.settings.gossip_port ];

    services.wgautomesh.settings = {
      gossip_secret_file = mkIf cfg.enableGossipEncryption "$CREDENTIALS_DIRECTORY/gossip_secret";
      persist_file = mkIf cfg.enablePersistence "/var/lib/wgautomesh/state";
    };

    systemd.services.wgautomesh = {
      description = "wgautomesh";

      environment = {
        RUST_LOG = "wgautomesh=${cfg.logLevel}";
      };

      path = [ pkgs.wireguard-tools ];

      serviceConfig = {
        AmbientCapabilities = "CAP_NET_ADMIN";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
        DynamicUser = true;
        ExecStart = "${getExe pkgs.wgautomesh} ${runtimeConfigFile}";

        ExecStartPre = mkIf cfg.enableGossipEncryption [
          ''
            ${pkgs.envsubst}/bin/envsubst \
                          -i ${configFile} \
                          -o ${runtimeConfigFile}''
        ];

        LoadCredential = mkIf cfg.enableGossipEncryption [ "gossip_secret:${cfg.gossipSecretFile}" ];
        Restart = "always";
        RestartSec = "30";
        RuntimeDirectory = "wgautomesh";
        StateDirectory = "wgautomesh";
        StateDirectoryMode = "0700";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
