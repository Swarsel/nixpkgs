{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  inherit (lib)
    attrValues
    concatLines
    concatMap
    filter
    filterAttrsRecursive
    flatten
    getExe
    mkIf
    optional
    ;

  cfg = config.services.rosenpass;
  opt = options.services.rosenpass;
  settingsFormat = pkgs.formats.toml { };
in
{
  options.services.rosenpass =
    let
      inherit (lib)
        literalExpression
        mkOption
        ;
      inherit (lib.types)
        enum
        listOf
        nullOr
        path
        str
        submodule
        ;
    in
    {
      enable = lib.mkEnableOption "Rosenpass";
      package = lib.mkPackageOption pkgs "rosenpass" { };

      defaultDevice = mkOption {
        description = "Name of the network interface to use for all peers by default.";
        example = "wg0";
        type = nullOr str;
      };

      settings = mkOption {
        default = { };
        description = "Configuration for Rosenpass, see <https://rosenpass.eu/> for further information.";

        type = submodule {
          options = {
            listen = mkOption {
              default = [ ];
              description = "List of local endpoints to listen for connections.";
              example = literalExpression "[ \"0.0.0.0:10000\" ]";
              type = listOf str;
            };

            peers =
              let
                peer = submodule {
                  options = {
                    device = mkOption {
                      default = cfg.defaultDevice;
                      defaultText = literalExpression "config.${opt.defaultDevice}";
                      description = "Name of the local WireGuard interface to use for this peer.";
                      type = str;
                    };

                    endpoint = mkOption {
                      default = null;
                      description = "Endpoint of the remote Rosenpass peer.";
                      type = nullOr str;
                    };

                    peer = mkOption {
                      description = "WireGuard public key corresponding to the remote Rosenpass peer.";
                      type = str;
                    };

                    public_key = mkOption {
                      description = "Path to a file containing the public key of the remote Rosenpass peer.";
                      type = path;
                    };
                  };

                  freeformType = settingsFormat.type;
                };
              in
              mkOption {
                default = [ ];
                description = "List of peers to exchange keys with.";
                type = listOf peer;
              };

            public_key = mkOption {
              description = "Path to a file containing the public key of the local Rosenpass peer. Generate this by running {command}`rosenpass gen-keys`.";
              type = path;
            };

            secret_key = mkOption {
              description = "Path to a file containing the secret key of the local Rosenpass peer. Generate this by running {command}`rosenpass gen-keys`.";
              type = path;
            };

            verbosity = mkOption {
              default = "Quiet";
              description = "Verbosity of output produced by the service.";

              type = enum [
                "Verbose"
                "Quiet"
              ];
            };
          };

          freeformType = settingsFormat.type;
        };
      };
    };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      pkgs.wireguard-tools
    ];

    systemd.services.rosenpass =
      let
        filterNonNull = filterAttrsRecursive (_: v: v != null);
        config = settingsFormat.generate "config.toml" (
          filterNonNull (
            cfg.settings
            // (
              let
                credentialPath = id: "$CREDENTIALS_DIRECTORY/${id}";
                # NOTE: We would like to remove all `null` values inside `cfg.settings`
                # recursively, since `settingsFormat.generate` cannot handle `null`.
                # This would require to traverse both attribute sets and lists recursively.
                # `filterAttrsRecursive` only recurses into attribute sets, but not
                # into values that might contain other attribute sets (such as lists,
                # e.g. `cfg.settings.peers`). Here, we just specialize on `cfg.settings.peers`,
                # and this may break unexpectedly whenever a `null` value is contained
                # in a list in `cfg.settings`, other than `cfg.settings.peers`.
                peersWithoutNulls = map filterNonNull cfg.settings.peers;
              in
              {
                peers = peersWithoutNulls;
                public_key = credentialPath "pqpk";
                secret_key = credentialPath "pqsk";
              }
            )
          )
        );
      in
      rec {
        after = [ "network-online.target" ];
        # See <https://www.freedesktop.org/software/systemd/man/systemd.unit.html#Specifiers>
        environment.CONFIG = "%t/${serviceConfig.RuntimeDirectory}/config.toml";

        path = [
          cfg.package
          pkgs.wireguard-tools
        ];

        script = ''
          ${getExe pkgs.envsubst} -i ${config} -o "$CONFIG"
          rosenpass exchange-config "$CONFIG"
        '';

        serviceConfig = {
          AmbientCapabilities = [ "CAP_NET_ADMIN" ];
          DynamicUser = true;
          Group = "rosenpass";

          LoadCredential = [
            "pqsk:${cfg.settings.secret_key}"
            "pqpk:${cfg.settings.public_key}"
          ];

          RuntimeDirectory = "rosenpass";
          User = "rosenpass";
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      };

    warnings =
      let
        # NOTE: In the descriptions below, we tried to refer to e.g.
        # options.systemd.network.netdevs."<name>".wireguardPeers.*.PublicKey
        # directly, but don't know how to traverse "<name>" and * in this path.
        extractions = [
          {
            description = "${options.systemd.network.netdevs}.\"<name>\".wireguardPeers.*.PublicKey";
            key = x: x.PublicKey or null;
            peer = (x: x.wireguardPeers);
            relevant = config.systemd.network.enable;
            root = config.systemd.network.netdevs;
          }
          {
            description = "${options.networking.wireguard.interfaces}.\"<name>\".peers.*.publicKey";
            key = (x: x.publicKey);
            peer = (x: x.peers);
            relevant = config.networking.wireguard.enable;
            root = config.networking.wireguard.interfaces;
          }
          rec {
            description = "${options.networking.wg-quick.interfaces}.\"<name>\".peers.*.publicKey";
            key = (x: x.publicKey);
            peer = (x: x.peers);
            relevant = root != { };
            root = config.networking.wg-quick.interfaces;
          }
        ];
        relevantExtractions = filter (x: x.relevant) extractions;
        extract =
          {
            key,
            peer,
            root,
            ...
          }:
          filter (x: x != null) (flatten (concatMap (x: (map key (peer x))) (attrValues root)));
        configuredKeys = flatten (map extract relevantExtractions);
        itemize = xs: concatLines (map (x: " - ${x}") xs);
        descriptions = map (x: "`${x.description}`");
        missingKeys = filter (key: !builtins.elem key configuredKeys) (map (x: x.peer) cfg.settings.peers);
        unusual = ''
          While this may work as expected, e.g. you want to manually configure WireGuard,
          such a scenario is unusual. Please double-check your configuration.
        '';
      in
      (optional (relevantExtractions != [ ] && missingKeys != [ ]) ''
        You have configured Rosenpass peers with the WireGuard public keys:
        ${itemize missingKeys}
        But there is no corresponding active Wireguard peer configuration in any of:
        ${itemize (descriptions relevantExtractions)}
        ${unusual}
      '')
      ++ optional (relevantExtractions == [ ]) ''
        You have configured Rosenpass, but you have not configured Wireguard via any of:
        ${itemize (descriptions extractions)}
        ${unusual}
      '';
  };
}
