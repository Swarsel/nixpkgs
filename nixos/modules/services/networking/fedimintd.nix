{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatLists
    filterAttrs
    mapAttrs'
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    mkOverride
    mkPackageOption
    nameValuePair
    recursiveUpdate
    types
    ;

  fedimintdOpts =
    {
      config,
      lib,
      name,
      ...
    }:
    {
      options = {
        enable = mkEnableOption "fedimintd";
        package = mkPackageOption pkgs "fedimint" { };

        api_iroh = {
          bind = mkOption {
            default = "0.0.0.0";
            description = "Address to bind on for Iroh endpoint for API connections";
            type = types.str;
          };

          openFirewall = mkOption {
            default = true;
            description = "Opens UDP port in firewall for fedimintd's API Iroh endpoint";
            type = types.bool;
          };

          port = mkOption {
            default = 8174;
            description = "UDP Port to bind Iroh endpoint for API connections";
            type = types.port;
          };
        };

        api_ws = {
          bind = mkOption {
            default = "127.0.0.1";
            description = "Address to bind on for API connections relied by the reverse proxy/tls terminator.";
            type = types.str;
          };

          openFirewall = mkOption {
            default = false;
            description = "Opens TCP port in firewall for fedimintd's Websocket API";
            type = types.bool;
          };

          port = mkOption {
            default = 8174;
            description = "TCP Port to bind on for API connections relayed by the reverse proxy/tls terminator.";
            type = types.port;
          };

          url = mkOption {
            description = ''
              Public URL of the API address of the reverse proxy/tls terminator. Usually starting with `wss://`.
            '';

            type = types.nullOr types.str;
          };
        };

        bitcoin = {
          network = mkOption {
            default = "signet";
            description = "Bitcoin network to participate in.";
            example = "bitcoin";
            type = types.str;
          };

          rpc = {
            kind = mkOption {
              default = "bitcoind";
              description = "Kind of a bitcoin node.";
              example = "electrum";
              type = types.str;
            };

            secretFile = mkOption {
              default = null;

              description = ''
                If set the URL specified in `bitcoin.rpc.url` will get the content of this file added
                as an URL password, so `http://user@example.com` will turn into `http://user:SOMESECRET@example.com`.

                Example:

                `/etc/nix-bitcoin-secrets/bitcoin-rpcpassword-public` (for nix-bitcoin default)
              '';

              type = types.nullOr types.path;
            };

            url = mkOption {
              default = "http://127.0.0.1:38332";
              description = "Bitcoin node (bitcoind/electrum/esplora) address to connect to";
              example = "signet";
              type = types.str;
            };
          };
        };

        consensus.finalityDelay = mkOption {
          default = 10;
          description = "Consensus peg-in finality delay.";
          type = types.ints.unsigned;
        };

        dataDir = mkOption {
          default = "/var/lib/fedimintd-${name}/";

          description = ''
            Path to the data dir fedimintd will use to store its data.
            Note that due to using the DynamicUser feature of systemd, this value should not be changed
            and is set to be read only.
          '';

          readOnly = true;
          type = types.path;
        };

        environment = mkOption {
          default = {
            RUST_BACKTRACE = "1";
          };

          description = "Extra Environment variables to pass to the fedimintd.";

          example = {
            RUST_BACKTRACE = "1";
            RUST_LOG = "info,fm=debug";
          };

          type = types.attrsOf types.str;
        };

        nginx = {
          config = mkOption {
            default = { };
            description = "Overrides to the nginx vhost section for api";

            type = types.submodule (
              recursiveUpdate (import ../web-servers/nginx/vhost-options.nix {
                inherit config lib;
              }) { }
            );
          };

          enable = mkOption {
            default = false;

            description = ''
              Whether to configure nginx for fedimintd
            '';

            type = types.bool;
          };

          fqdn = mkOption {
            description = "Public domain of the API address of the reverse proxy/tls terminator.";
            example = "api.myfedimint.com";
            type = types.str;
          };

          path_ui = mkOption {
            default = "/";
            description = "Path to host the built-in UI on and forward to the daemon's api port";
            example = "/";
            type = types.str;
          };

          path_ws = mkOption {
            default = "/ws/";
            description = "Path to host the API on and forward to the daemon's api port";
            example = "/";
            type = types.str;
          };
        };

        p2p = {
          bind = mkOption {
            default = "0.0.0.0";
            description = "Address to bind on for p2p connections from peers (both TCP and UDP)";
            type = types.str;
          };

          openFirewall = mkOption {
            default = true;
            description = "Opens port in firewall for fedimintd's p2p port (both TCP and UDP)";
            type = types.bool;
          };

          port = mkOption {
            default = 8173;
            description = "Port to bind on for p2p connections from peers (both TCP and UDP)";
            type = types.port;
          };

          url = mkOption {
            description = ''
              Public address for p2p connections from peers (if TCP is used)
            '';

            example = "fedimint://p2p.myfedimint.com:8173";
            type = types.nullOr types.str;
          };
        };

        ui = {
          bind = mkOption {
            default = "127.0.0.1";
            description = "Address to bind on for UI connections";
            type = types.str;
          };

          openFirewall = mkOption {
            default = false;
            description = "Opens TCP port in firewall for built-in UI";
            type = types.bool;
          };

          port = mkOption {
            default = 8175;
            description = "TCP Port to bind on for UI connections";
            type = types.port;
          };
        };
      };
    };
in
{
  options = {
    services.fedimintd = mkOption {
      default = { };
      description = "Specification of one or more fedimintd instances.";
      type = types.attrsOf (types.submodule fedimintdOpts);
    };
  };

  config =
    let
      eachFedimintd = filterAttrs (fedimintdName: cfg: cfg.enable) config.services.fedimintd;
      eachFedimintdNginx = filterAttrs (fedimintdName: cfg: cfg.nginx.enable) eachFedimintd;
    in
    mkIf (eachFedimintd != { }) {

      networking.firewall.allowedTCPPorts = concatLists (
        mapAttrsToList (
          fedimintdName: cfg:
          (
            lib.optional cfg.api_ws.openFirewall cfg.api_ws.port
            ++ lib.optional cfg.p2p.openFirewall cfg.p2p.port
            ++ lib.optional cfg.ui.openFirewall cfg.ui.port
          )
        ) eachFedimintd
      );

      networking.firewall.allowedUDPPorts = concatLists (
        mapAttrsToList (
          fedimintdName: cfg:
          (
            lib.optional cfg.api_iroh.openFirewall cfg.api_iroh.port
            ++ lib.optional cfg.p2p.openFirewall cfg.p2p.port
          )
        ) eachFedimintd
      );

      services.nginx.virtualHosts = mapAttrs' (
        fedimintdName: cfg:
        (nameValuePair cfg.nginx.fqdn (
          lib.mkMerge [
            cfg.nginx.config

            {
              # Note: we want by default to enable OpenSSL, but it seems anything 100 and above is
              # overridden by default value from vhost-options.nix
              enableACME = mkOverride 99 true;
              forceSSL = mkOverride 99 true;

              locations.${cfg.nginx.path_ui} = {
                extraConfig = ''
                  proxy_pass_header Authorization;
                '';

                proxyPass = "http://127.0.0.1:${toString cfg.ui.port}/";
              };

              locations.${cfg.nginx.path_ws} = {
                extraConfig = ''
                  proxy_pass_header Authorization;
                '';

                proxyPass = "http://127.0.0.1:${toString cfg.api_ws.port}/";
                proxyWebsockets = true;
              };
            }
          ]
        ))
      ) eachFedimintdNginx;

      systemd.services = mapAttrs' (
        fedimintdName: cfg:
        (nameValuePair "fedimintd-${fedimintdName}" (
          let
            startScript = pkgs.writeShellScriptBin "fedimintd" (
              (
                if cfg.bitcoin.rpc.secretFile != null then
                  ''
                    >&2 echo "Setting FM_FORCE_BITCOIN_RPC_URL using password from ${cfg.bitcoin.rpc.secretFile}"
                    secret=$(${pkgs.coreutils}/bin/head -n 1 "${cfg.bitcoin.rpc.secretFile}" || exit 1)
                    export FM_FORCE_BITCOIN_RPC_URL=$(echo "$FM_BITCOIN_RPC_URL" | sed "s|^\(\w\+://[^@]\+\)\(@.*\)|\1:''${secret}\2|")
                  ''
                else
                  ""
              )
              + ''
                exec ${cfg.package}/bin/fedimintd
              ''
            );
          in
          {
            description = "Fedimint Server";
            documentation = [ "https://github.com/fedimint/fedimint/" ];

            environment = lib.mkMerge [
              {
                FM_BIND_API_IROH = "${cfg.api_iroh.bind}:${toString cfg.api_iroh.port}";
                FM_BIND_API_WS = "${cfg.api_ws.bind}:${toString cfg.api_ws.port}";
                FM_BIND_P2P = "${cfg.p2p.bind}:${toString cfg.p2p.port}";
                FM_BIND_UI = "${cfg.ui.bind}:${toString cfg.ui.port}";
                FM_BITCOIN_NETWORK = cfg.bitcoin.network;
                FM_BITCOIN_RPC_KIND = cfg.bitcoin.rpc.kind;
                FM_BITCOIN_RPC_URL = cfg.bitcoin.rpc.url;
                FM_DATA_DIR = cfg.dataDir;
              }

              (lib.optionalAttrs (cfg.p2p.url != null) {
                FM_P2P_URL = cfg.p2p.url;
              })

              (lib.optionalAttrs (cfg.api_ws.url != null) {
                FM_API_URL = cfg.api_ws.url;
              })

              cfg.environment
            ];

            serviceConfig = {
              DynamicUser = true;
              ExecStart = "${startScript}/bin/fedimintd";
              LimitNOFILE = "100000";
              LockPersonality = true;
              MemoryDenyWriteExecute = true;
              NoNewPrivileges = true;
              PrivateDevices = true;
              PrivateMounts = true;
              PrivateTmp = true;
              ProtectClock = true;
              ProtectControlGroups = true;
              ProtectHostname = true;
              ProtectKernelLogs = true;
              ProtectKernelModules = true;
              ProtectKernelTunables = true;
              ProtectSystem = "full";
              Restart = "always";
              RestartSec = 10;

              RestrictAddressFamilies = [
                "AF_INET"
                "AF_INET6"
                "AF_NETLINK"
              ];

              RestrictNamespaces = true;
              RestrictRealtime = true;
              SocketBindAllow = "udp:${toString cfg.api_iroh.port}";
              StateDirectory = "fedimintd-${fedimintdName}";
              StateDirectoryMode = "0700";
              SystemCallArchitectures = "native";

              SystemCallFilter = [
                "@system-service"
                "~@privileged"
              ];

              UMask = "007";
            };

            unitConfig = {
              StartLimitBurst = 5;
            };

            wantedBy = [ "multi-user.target" ];
          }
        ))
      ) eachFedimintd;
    };

  meta.maintainers = with lib.maintainers; [ dpc ];
}
