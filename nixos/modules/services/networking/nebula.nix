{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.nebula;
  enabledNetworks = lib.filterAttrs (n: v: v.enable) cfg.networks;

  genSettings =
    netName: netCfg:
    lib.recursiveUpdate {
      firewall = {
        inbound = netCfg.firewall.inbound;
        outbound = netCfg.firewall.outbound;
      };

      lighthouse = {
        am_lighthouse = netCfg.isLighthouse;
        dns.host = netCfg.lighthouse.dns.host;
        dns.port = netCfg.lighthouse.dns.port;
        hosts = netCfg.lighthouses;
        serve_dns = netCfg.lighthouse.dns.enable;
      };

      listen = {
        host = netCfg.listen.host;
        port = resolveFinalPort netCfg;
      };

      pki = {
        ca = netCfg.ca;
        cert = netCfg.cert;
        key = netCfg.key;
      };

      relay = {
        am_relay = netCfg.isRelay;
        relays = netCfg.relays;
        use_relays = true;
      };

      static_host_map = netCfg.staticHostMap;

      tun = {
        dev = if (netCfg.tun.device != null) then netCfg.tun.device else "nebula.${netName}";
        disabled = netCfg.tun.disable;
      };
    } netCfg.settings;
  format = pkgs.formats.yaml { };

  genConfigFile =
    netName: settings:
    format.generate "nebula-config-${netName}.yml" (
      lib.warnIf
        ((settings.lighthouse.am_lighthouse || settings.relay.am_relay) && settings.listen.port == 0)
        ''
          Nebula network '${netName}' is configured as a lighthouse or relay, and its port is ${toString settings.listen.port}.
          You will likely experience connectivity issues: https://nebula.defined.net/docs/config/listen/#listenport
        ''
        settings
    );

  nameToId = netName: "nebula-${netName}";

  resolveFinalPort =
    netCfg:
    if netCfg.listen.port == null then
      if (netCfg.isLighthouse || netCfg.isRelay) then 4242 else 0
    else
      netCfg.listen.port;
in
{
  # Interface

  options = {
    services.nebula = {
      networks = lib.mkOption {
        default = { };
        description = "Nebula network definitions.";

        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              enable = lib.mkOption {
                default = true;
                description = "Enable or disable this network.";
                type = lib.types.bool;
              };

              package = lib.mkPackageOption pkgs "nebula" { };

              ca = lib.mkOption {
                description = "Path to the certificate authority certificate.";
                example = "/etc/nebula/ca.crt";
                type = lib.types.path;
              };

              cert = lib.mkOption {
                description = "Path to the host certificate.";
                example = "/etc/nebula/host.crt";
                type = lib.types.path;
              };

              enableReload = lib.mkOption {
                default = false;

                description = ''
                  Enable automatic config reload on config change.
                  This setting is not enabled by default as nix cannot determine if the config change is reloadable.
                  Please refer to the [config reference](https://nebula.defined.net/docs/config/) for documentation on reloadable changes.
                '';

                type = lib.types.bool;
              };

              firewall.inbound = lib.mkOption {
                default = [ ];
                description = "Firewall rules for inbound traffic.";

                example = [
                  {
                    host = "any";
                    port = "any";
                    proto = "any";
                  }
                ];

                type = lib.types.listOf lib.types.attrs;
              };

              firewall.outbound = lib.mkOption {
                default = [ ];
                description = "Firewall rules for outbound traffic.";

                example = [
                  {
                    host = "any";
                    port = "any";
                    proto = "any";
                  }
                ];

                type = lib.types.listOf lib.types.attrs;
              };

              isLighthouse = lib.mkOption {
                default = false;
                description = "Whether this node is a lighthouse.";
                type = lib.types.bool;
              };

              isRelay = lib.mkOption {
                default = false;
                description = "Whether this node is a relay.";
                type = lib.types.bool;
              };

              key = lib.mkOption {
                description = "Path or reference to the host key.";
                example = "/etc/nebula/host.key";

                type = lib.types.oneOf [
                  lib.types.nonEmptyStr
                  lib.types.path
                ];
              };

              lighthouse.dns.enable = lib.mkOption {
                default = false;
                description = "Whether this lighthouse node should serve DNS.";
                type = lib.types.bool;
              };

              lighthouse.dns.host = lib.mkOption {
                default = "localhost";

                description = ''
                  IP address on which nebula lighthouse should serve DNS.
                  'localhost' is a good default to ensure the service does not listen on public interfaces;
                  use a Nebula address like 10.0.0.5 to make DNS resolution available to nebula hosts only.
                '';

                type = lib.types.str;
              };

              lighthouse.dns.port = lib.mkOption {
                default = 5353;
                description = "UDP port number for lighthouse DNS server.";
                type = lib.types.nullOr lib.types.port;
              };

              lighthouses = lib.mkOption {
                default = [ ];

                description = ''
                  List of IPs of lighthouse hosts this node should report to and query from. This should be empty on lighthouse
                  nodes. The IPs should be the lighthouse's Nebula IPs, not their external IPs.
                '';

                example = [ "192.168.100.1" ];
                type = lib.types.listOf lib.types.str;
              };

              listen.host = lib.mkOption {
                default = "0.0.0.0";
                description = "IP address to listen on.";
                type = lib.types.str;
              };

              listen.port = lib.mkOption {
                default = null;

                defaultText = lib.literalExpression ''
                  if (config.services.nebula.networks.''${name}.isLighthouse ||
                      config.services.nebula.networks.''${name}.isRelay) then
                    4242
                  else
                    0;
                '';

                description = "Port number to listen on.";
                type = lib.types.nullOr lib.types.port;
              };

              relays = lib.mkOption {
                default = [ ];

                description = ''
                  List of IPs of relays that this node should allow traffic from.
                '';

                example = [ "192.168.100.1" ];
                type = lib.types.listOf lib.types.str;
              };

              settings = lib.mkOption {
                default = { };

                description = ''
                  Nebula configuration. Refer to
                  <https://github.com/slackhq/nebula/blob/master/examples/config.yml>
                  for details on supported values.
                '';

                example = lib.literalExpression ''
                  {
                    lighthouse.interval = 15;
                  }
                '';

                type = format.type;
              };

              staticHostMap = lib.mkOption {
                default = { };

                description = ''
                  The static host map defines a set of hosts with fixed IP addresses on the internet (or any network).
                  A host can have multiple fixed IP addresses defined here, and nebula will try each when establishing a tunnel.
                '';

                example = {
                  "192.168.100.1" = [ "100.64.22.11:4242" ];
                };

                type = lib.types.attrsOf (lib.types.listOf (lib.types.str));
              };

              tun.device = lib.mkOption {
                default = null;
                description = "Name of the tun device. Defaults to nebula.\${networkName}.";
                type = lib.types.nullOr lib.types.str;
              };

              tun.disable = lib.mkOption {
                default = false;

                description = ''
                  When tun is disabled, a lighthouse can be started without a local tun interface (and therefore without root).
                '';

                type = lib.types.bool;
              };
            };
          }
        );
      };
    };
  };

  # Implementation
  config = lib.mkIf (enabledNetworks != { }) {
    environment.etc = lib.mkMerge (
      lib.mapAttrsToList
        (netName: netCfg: {
          "nebula/${netName}.yml" = {
            mode = "0440";
            source = genConfigFile netName (genSettings netName netCfg);
            user = nameToId netName;
          };
        })
        (
          lib.filterAttrs (
            _: netCfg: netCfg.enableReload || (lib.versionAtLeast config.system.stateVersion "25.11")
          ) enabledNetworks
        )
    );

    # Open the chosen ports for UDP.
    networking.firewall.allowedUDPPorts = lib.unique (
      lib.filter (port: port > 0) (
        lib.mapAttrsToList (netName: netCfg: resolveFinalPort netCfg) enabledNetworks
      )
    );

    systemd.services = lib.mkMerge (
      lib.mapAttrsToList (
        netName: netCfg:
        let
          networkId = nameToId netName;
          settings = genSettings netName netCfg;
          generatedConfigFile = genConfigFile netName settings;
          configFile =
            if ((lib.versionAtLeast config.system.stateVersion "25.11") || netCfg.enableReload) then
              "/etc/nebula/${netName}.yml"
            else
              generatedConfigFile;
          capabilities =
            let
              nebulaPort = if !settings.tun.disabled then settings.listen.port else 0;
              dnsPort = if settings.lighthouse.serve_dns then settings.lighthouse.dns.port else 0;
            in
            lib.concatStringsSep " " (
              # creation of tunnel interfaces
              lib.optional (!settings.tun.disabled) "CAP_NET_ADMIN"
              # binding to privileged ports
              ++ lib.optional (
                nebulaPort > 0 && nebulaPort < 1024 || dnsPort > 0 && dnsPort < 1024
              ) "CAP_NET_BIND_SERVICE"
            );
        in
        {
          # Create the systemd service for Nebula.
          "nebula@${netName}" = {
            after = [
              "basic.target"
              "network.target"
            ];

            before = [ "sshd.service" ];
            description = "Nebula VPN service for ${netName}";
            reloadTriggers = lib.optional netCfg.enableReload generatedConfigFile;
            restartTriggers = lib.optional (!netCfg.enableReload) generatedConfigFile;

            serviceConfig = {
              AmbientCapabilities = capabilities;
              CapabilityBoundingSet = capabilities;
              DeviceAllow = "/dev/net/tun rw";
              DevicePolicy = "closed";
              ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
              ExecStart = "${netCfg.package}/bin/nebula -config ${configFile}";
              Group = networkId;
              LockPersonality = true;
              NoNewPrivileges = true;
              PrivateDevices = false; # needs access to /dev/net/tun (below)
              PrivateTmp = true;
              PrivateUsers = false; # CapabilityBoundingSet needs to apply to the host namespace
              ProtectClock = true;
              ProtectControlGroups = true;
              ProtectHome = true;
              ProtectHostname = true;
              ProtectKernelLogs = true;
              ProtectKernelModules = true;
              ProtectKernelTunables = true;
              ProtectProc = "invisible";
              ProtectSystem = true;
              Restart = "always";
              RestrictNamespaces = true;
              RestrictSUIDSGID = true;
              Type = "notify";
              UMask = "0027";
              User = networkId;
            };

            unitConfig.StartLimitIntervalSec = 0; # ensure Restart=always is always honoured (networks can go down for arbitrarily long)
            wantedBy = [ "multi-user.target" ];
            wants = [ "basic.target" ];
          };
        }
      ) enabledNetworks
    );

    users.groups = lib.mkMerge (
      lib.mapAttrsToList (netName: netCfg: {
        ${nameToId netName} = { };
      }) enabledNetworks
    );

    # Create the service users and groups.
    users.users = lib.mkMerge (
      lib.mapAttrsToList (netName: netCfg: {
        ${nameToId netName} = {
          description = "Nebula service user for network ${netName}";
          group = nameToId netName;
          isSystemUser = true;
        };
      }) enabledNetworks
    );
  };

  meta.maintainers = with lib.maintainers; [
    numinit
    siriobalmelli
  ];
}
