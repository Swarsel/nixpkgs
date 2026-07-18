{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    attrValues
    concatLists
    concatStringsSep
    escapeShellArgs
    filterAttrs
    getExe
    listToAttrs
    literalExpression
    maintainers
    makeBinPath
    mapAttrs'
    mapAttrsToList
    mkAliasOptionModule
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkOptionDefault
    mkOverride
    mkPackageOption
    nameValuePair
    optional
    optionalAttrs
    optionalString
    optionals
    pipe
    toShellVars
    versionAtLeast
    versionOlder
    ;

  inherit (lib.types)
    attrsOf
    bool
    enum
    listOf
    nullOr
    package
    path
    port
    str
    submodule
    ;

  inherit (config.boot) kernelPackages;
  inherit (config.boot.kernelPackages) kernel;

  cfg = config.services.netbird;

  toClientList = fn: map fn (attrValues cfg.clients);
  toClientAttrs = fn: mapAttrs' (_: fn) cfg.clients;

  hardenedClients = filterAttrs (_: client: client.hardened) cfg.clients;
  toHardenedClientList = fn: map fn (attrValues hardenedClients);
  toHardenedClientAttrs = fn: mapAttrs' (_: fn) hardenedClients;

  mkBinName =
    client: name:
    if client.bin.suffix == "" || client.bin.suffix == "netbird" then
      name
    else
      "${name}-${client.bin.suffix}";

  nixosConfig = config;
in
{
  imports = [
    (mkAliasOptionModule [ "services" "netbird" "tunnels" ] [ "services" "netbird" "clients" ])
  ];

  options.services.netbird = {
    enable = mkOption {
      default = false;

      description = ''
        Enables backward-compatible NetBird client service.

        This is strictly equivalent to:

        ```nix
        services.netbird.clients.default = {
          port = 51820;
          name = "netbird";
          interface = "wt0";
          hardened = false;
        };
        ```
      '';

      type = bool;
    };

    package = mkPackageOption pkgs "netbird" { };

    clients = mkOption {
      default = { };

      description = ''
        Attribute set of NetBird client daemons, by default each one will:

        1. be manageable using dedicated tooling:
          - `netbird-<name>` script,
          - `NetBird - netbird-<name>` graphical interface when appropriate (see `ui.enable`),
        2. run as a `netbird-<name>.service`,
        3. listen for incoming remote connections on the port `51820` (`openFirewall` by default),
        4. manage the `netbird-<name>` wireguard interface,
        5. use the {file}`/var/lib/netbird-<name>/config.json` configuration file,
        6. override {file}`/var/lib/netbird-<name>/config.json` with values from {file}`/etc/netbird-<name>/config.d/*.json`,
        7. (`hardened`) be locally manageable by `netbird-<name>` system group,

        With following caveats:

        - multiple daemons will interfere with each other's DNS resolution of `netbird.cloud`, but
          should remain fully operational otherwise.
          Setting up custom (non-conflicting) DNS zone is currently possible only when self-hosting.
      '';

      example = lib.literalExpression ''
        {
          services.netbird.clients.wt0.port = 51820;
          services.netbird.clients.personal.port = 51821;
          services.netbird.clients.work1.port = 51822;
        }
      '';

      type = attrsOf (
        submodule (
          { config, name, ... }:
          let
            client = config;
          in
          {
            options = {
              # see https://github.com/netbirdio/netbird/blob/88747e3e0191abc64f1e8c7ecc65e5e50a1527fd/client/internal/config.go#L49-L82
              config = mkOption {
                defaultText = literalExpression ''
                  {
                    DisableAutoConnect = !client.autoStart;
                    WgIface = client.interface;
                    WgPort = client.port;
                  } // optionalAttrs (client.dns-resolver.address != null) {
                    CustomDNSAddress = "''${client.dns-resolver.address}:''${toString client.dns-resolver.port}";
                  }
                '';

                description = ''
                  Additional configuration that exists before the first start and
                  later overrides the existing values in {file}`config.json`.

                  It is mostly helpful to manage configuration ignored/not yet implemented
                  outside of `netbird up` invocation.

                  WARNING: this is not an upstream feature, it could break in the future
                  (by having lower priority) after upstream implements an equivalent.

                  It is implemented as a `preStart` script which overrides {file}`config.json`
                  with content of {file}`/etc/${client.dir.baseName}/config.d/*.json` files.
                  This option manages specifically {file}`50-nixos.json` file.

                  Consult [the source code](https://github.com/netbirdio/netbird/blob/88747e3e0191abc64f1e8c7ecc65e5e50a1527fd/client/internal/config.go#L49-L82)
                  or inspect existing file for a complete list of available configurations.
                '';

                type = (pkgs.formats.json { }).type;
              };

              autoStart = mkOption {
                default = true;

                description = ''
                  Start the service with the system.

                  As of 2024-02-13 it is not possible to start a NetBird client daemon without immediately
                  connecting to the network, but it is [planned for a near future](https://github.com/netbirdio/netbird/projects/2#card-91718018).
                '';

                type = bool;
              };

              bin.suffix = mkOption {
                default = if client.name != "netbird" then client.name else "";

                description = ''
                  A system group name for this client instance.
                '';

                type = str;
              };

              dir.baseName = mkOption {
                default = client.suffixedName;

                description = ''
                  A systemd service name to use (without `.service` suffix).
                '';

                type = str;
              };

              dir.runtime = mkOption {
                default = "/var/run/${client.dir.baseName}";

                description = ''
                  A runtime directory used by NetBird client.
                '';

                type = path;
              };

              dir.state = mkOption {
                default = "/var/lib/${client.dir.baseName}";

                description = ''
                  A state directory used by NetBird client to store {file}`config.json`, {file}`state.json` & {file}`resolv.conf`.
                '';

                type = path;
              };

              dns-resolver.address = mkOption {
                default = null;

                description = ''
                  An explicit address that NetBird will serve `*.netbird.cloud.` (usually) entries on.

                  NetBird serves DNS on it's own (dynamic) client address by default.
                '';

                example = "127.0.0.123";
                type = nullOr str;
              };

              dns-resolver.port = mkOption {
                default = 53;

                description = ''
                  A port to serve DNS entries on when `dns-resolver.address` is enabled.
                '';

                type = port;
              };

              environment = mkOption {
                defaultText = literalExpression ''
                  {
                    NB_STATE_DIR = client.dir.state;
                    NB_CONFIG = "''${client.dir.state}/config.json";
                    NB_DAEMON_ADDR = "unix://''${client.dir.runtime}/sock";
                    NB_INTERFACE_NAME = client.interface;
                    NB_LOG_FILE = mkOptionDefault "console";
                    NB_LOG_LEVEL = client.logLevel;
                    NB_SERVICE = client.service.name;
                    NB_WIREGUARD_PORT = toString client.port;
                  } // optionalAttrs (client.dns-resolver.address != null) {
                    NB_DNS_RESOLVER_ADDRESS = "''${client.dns-resolver.address}:''${toString client.dns-resolver.port}";
                  }
                '';

                description = ''
                  Environment for the netbird service, used to pass configuration options.
                '';

                type = attrsOf str;
              };

              hardened = mkOption {
                default = true;

                description = ''
                  Hardened service:
                  - runs as a dedicated user with minimal set of permissions (see caveats),
                  - restricts daemon configuration socket access to dedicated user group
                    (you can grant access to it with `users.users."<user>".extraGroups = [ ${client.user.group} ]`),

                  Even though the local system resources access is restricted:
                  - `CAP_NET_RAW`, `CAP_NET_ADMIN` and `CAP_BPF` still give unlimited network manipulation possibilites,
                  - older kernels don't have `CAP_BPF` and use `CAP_SYS_ADMIN` instead,

                  Known security features that are not (yet) integrated into the module:
                  - 2024-02-14: `rosenpass` is an experimental feature configurable solely
                    through `--enable-rosenpass` flag on the `netbird up` command,
                    see [the docs](https://docs.netbird.io/how-to/enable-post-quantum-cryptography)
                '';

                type = bool;
              };

              interface = mkOption {
                apply =
                  iface:
                  lib.throwIfNot (
                    builtins.stringLength iface <= 15
                  ) "Network interface name must be 15 characters or less" iface;

                default = "nb-${client.name}";

                description = ''
                  Name of the network interface managed by this client.
                '';

                type = str;
              };

              logLevel = mkOption {
                default = "info";
                description = "Log level of the NetBird daemon.";

                type = enum [
                  # logrus loglevels
                  "panic"
                  "fatal"
                  "error"
                  "warn"
                  "warning"
                  "info"
                  "debug"
                  "trace"
                ];
              };

              login.enable = mkEnableOption "automated login for NetBird client";

              login.setupKeyFile = mkOption {
                default = null;

                description = ''
                  A Setup Key file path used for automated login of the machine.
                '';

                example = "/run/secrets/netbird-priv/setup-key";
                type = nullOr str;
              };

              login.systemdDependencies = mkOption {
                default = [ ];

                description = ''
                  Additional systemd dependencies required to succeed before the Setup Key file becomes available.
                '';

                example = lib.literalExpression ''
                  [ "sops-install-secrets.service" ]
                '';

                type = listOf str;
              };

              name = mkOption {
                default = name;

                description = ''
                  Primary name for use (as a suffix) in:
                  - systemd service name,
                  - hardened user name and group,
                  - [systemd `*Directory=`](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#RuntimeDirectory=) names,
                  - desktop application identification,
                '';

                type = str;
              };

              openFirewall = mkOption {
                default = true;

                description = ''
                  Opens up firewall `port` for communication between NetBird peers directly over LAN or public IP,
                  without using (internet-hosted) TURN servers as intermediaries.
                '';

                type = bool;
              };

              openInternalFirewall = mkOption {
                default = true;

                description = ''
                  Opens up internal firewall ports for the NetBird's network interface.
                '';

                type = bool;
              };

              port = mkOption {
                description = ''
                  Port the NetBird client listens on.
                '';

                example = literalExpression "51820";
                type = port;
              };

              service.name = mkOption {
                default = client.suffixedName;

                description = ''
                  A systemd service name to use (without `.service` suffix).
                '';

                type = str;
              };

              suffixedName = mkOption {
                default = if client.name != "netbird" then "netbird-${client.name}" else client.name;

                description = ''
                  A systemd service name to use (without `.service` suffix).
                '';

                type = str;
              };

              ui.enable = mkOption {
                default = nixosConfig.services.netbird.ui.enable;
                defaultText = literalExpression "client.ui.enable";

                description = ''
                  Controls presence of `netbird-ui` wrapper for this NetBird client.
                '';

                type = bool;
              };

              user.group = mkOption {
                default = client.suffixedName;

                description = ''
                  A system group name for this client instance.
                '';

                type = str;
              };

              user.name = mkOption {
                default = client.suffixedName;

                description = ''
                  A system user name for this client instance.
                '';

                type = str;
              };

              wrapper = mkOption {
                default =
                  let
                    makeWrapperArgs = concatLists (
                      mapAttrsToList (key: value: [
                        "--set-default"
                        key
                        value
                      ]) client.environment
                    );
                    mkBin = mkBinName client;
                  in
                  pkgs.stdenv.mkDerivation {
                    buildCommand = concatStringsSep "\n" [
                      ''
                        mkdir -p "$out/bin"
                        makeWrapper ${lib.getExe cfg.package} "$out/bin/${mkBin "netbird"}" \
                          ${escapeShellArgs makeWrapperArgs}
                      ''
                      (optionalString cfg.ui.enable ''
                        # netbird-ui doesn't support envvars
                        makeWrapper ${lib.getExe cfg.ui.package} "$out/bin/${mkBin "netbird-ui"}" \
                          --add-flags '--daemon-addr=${client.environment.NB_DAEMON_ADDR}'

                        mkdir -p "$out/share/applications"
                        substitute ${cfg.ui.package}/share/applications/netbird.desktop \
                            "$out/share/applications/${mkBin "netbird"}.desktop" \
                          --replace-fail 'Name=Netbird' "Name=NetBird @ ${client.service.name}" \
                          --replace-fail 'Icon=netbird' "Icon=${cfg.ui.package}/share/icons/hicolor/256x256/apps/netbird.png" \
                          --replace-fail 'Exec=netbird-ui' "Exec=${mkBin "netbird-ui"}"
                      '')
                    ];

                    name = "${cfg.package.name}-wrapper-${client.name}";
                    nativeBuildInputs = with pkgs; [ makeWrapper ];
                    meta.mainProgram = mkBin "netbird";
                  };

                internal = true;
                type = package;
              };
            };

            config.config = {
              DisableAutoConnect = !client.autoStart;
              WgIface = client.interface;
              WgPort = client.port;
            }
            // optionalAttrs (client.dns-resolver.address != null) {
              CustomDNSAddress = "${client.dns-resolver.address}:${toString client.dns-resolver.port}";
            };

            config.environment = {
              NB_CONFIG = "${client.dir.state}/config.json";
              NB_DAEMON_ADDR = "unix://${client.dir.runtime}/sock";
              NB_INTERFACE_NAME = client.interface;
              NB_LOG_FILE = mkOptionDefault "console";
              NB_LOG_LEVEL = client.logLevel;
              NB_SERVICE = client.service.name;
              NB_STATE_DIR = client.dir.state;
              NB_WIREGUARD_PORT = toString client.port;
            }
            // optionalAttrs (client.dns-resolver.address != null) {
              NB_DNS_RESOLVER_ADDRESS = "${client.dns-resolver.address}:${toString client.dns-resolver.port}";
            };
          }
        )
      );
    };

    ui.enable = mkOption {
      default = config.services.displayManager.sessionPackages != [ ] || config.services.xserver.enable;

      defaultText = literalExpression ''
        config.services.displayManager.sessionPackages != [ ] || config.services.xserver.enable
      '';

      description = ''
        Controls presence `netbird-ui` wrappers, defaults to presence of graphical sessions.
      '';

      type = bool;
    };

    ui.package = mkPackageOption pkgs "netbird-ui" { };

    useRoutingFeatures = mkOption {
      default = "none";

      description = ''
        Enables settings required for NetBird's routing features: Network Resources, Network Routes & Exit Nodes.

        When set to `client` or `both`, reverse path filtering will be set to loose instead of strict.
        When set to `server` or `both`, IP forwarding will be enabled.
      '';

      example = "server";

      type = enum [
        "none"
        "client"
        "server"
        "both"
      ];
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.netbird.clients.default = {
        hardened = mkDefault false;
        interface = mkDefault "wt0";
        name = mkDefault "netbird";
        port = mkDefault 51820;
      };
    })
    {
      boot.extraModulePackages = optional (
        cfg.clients != { } && (versionOlder kernel.version "5.6")
      ) kernelPackages.wireguard;

      # Required for the routing ("Exit node") feature(s) to work
      boot.kernel.sysctl = mkIf (cfg.useRoutingFeatures == "server" || cfg.useRoutingFeatures == "both") {
        "net.ipv4.conf.all.forwarding" = mkOverride 97 true;
        "net.ipv6.conf.all.forwarding" = mkOverride 97 true;
      };

      environment.etc = toClientAttrs (
        client:
        nameValuePair "${client.dir.baseName}/config.d/50-nixos.json" {
          mode = "0444";
          text = builtins.toJSON client.config;
        }
      );

      environment.systemPackages = toClientList (client: client.wrapper)
      # omitted due to https://github.com/netbirdio/netbird/issues/1562
      #++ optional (cfg.clients != { }) cfg.package
      # omitted due to https://github.com/netbirdio/netbird/issues/1581
      #++ optional (cfg.clients != { } && cfg.ui.enable) cfg.ui.package
      ;

      networking.dhcpcd.denyInterfaces = toClientList (client: client.interface);

      networking.firewall = {
        allowedUDPPorts = concatLists (toClientList (client: optional client.openFirewall client.port));

        # Required for the routing ("Exit node") feature(s) to work
        checkReversePath = mkIf (
          cfg.useRoutingFeatures == "client" || cfg.useRoutingFeatures == "both"
        ) "loose";

        # Ports opened on a specific
        interfaces = lib.mkIf (config.networking.firewall.backend != "firewalld") (
          listToAttrs (
            toClientList (client: {
              name = client.interface;

              value.allowedUDPPorts = optionals client.openInternalFirewall [
                # note: those should be opened up by NetBird itself, but it needs additional
                #  NixOS -specific debugging and tweaking before it works
                5353 # <0.59.0 DNS forwarder port, kept for compatibility with those clients
                22054 # >=0.59.0 DNS forwarder port
              ];
            })
          )
        );
      };

      networking.networkmanager.unmanaged = toClientList (client: "interface-name:${client.interface}");

      services.firewalld.zones.netbird = {
        interfaces = lib.pipe cfg.clients [
          (lib.filterAttrs (_: client: client.openFirewall))
          lib.attrValues
          (map (client: client.interface))
        ];

        ports = [
          {
            port = 5353;
            protocol = "udp";
          }
        ];
      };

      systemd.network.networks = mkIf config.networking.useNetworkd (
        toClientAttrs (
          client:
          nameValuePair "50-netbird-${client.interface}" {
            linkConfig = {
              ActivationPolicy = "manual";
              Unmanaged = true;
            };

            matchConfig = {
              Name = client.interface;
            };
          }
        )
      );

      systemd.services = toClientAttrs (
        client:
        nameValuePair client.service.name {
          after = [ "network.target" ];
          description = "A WireGuard-based mesh network that connects your devices into a single private network";
          documentation = [ "https://netbird.io/docs/" ];
          path = [ pkgs.shadow ] ++ optionals (!config.services.resolved.enable) [ pkgs.openresolv ];

          serviceConfig = {
            ConfigurationDirectory = client.dir.baseName;
            ExecStart = "${getExe client.wrapper} service run";
            Restart = "always";
            RuntimeDirectory = client.dir.baseName;
            RuntimeDirectoryMode = mkDefault "0755";
            StateDirectory = client.dir.baseName;
            StateDirectoryMode = "0700";
            WorkingDirectory = client.dir.state;
          };

          stopIfChanged = false;

          unitConfig = {
            StartLimitBurst = 10;
            StartLimitInterval = 5;
          };

          wantedBy = [ "multi-user.target" ];
        }
      );
    }
    # netbird debug bundle related configurations
    {
      systemd.services = toClientAttrs (
        client:
        nameValuePair client.service.name {
          /*
            lets NetBird daemon know which systemd service to gather logs for
            see https://github.com/netbirdio/netbird/blob/2c87fa623654c5eef76bc0226062290201eef13a/client/internal/debug/debug_linux.go#L50-L51
          */
          environment.SYSTEMD_UNIT = client.service.name;

          path =
            optionals config.networking.nftables.enable [ pkgs.nftables ]
            ++ optionals (!config.networking.nftables.enable) [
              pkgs.iptables
              pkgs.ipset
            ];
        }
      );

      users.users = toHardenedClientAttrs (
        client:
        nameValuePair client.user.name {
          extraGroups = [
            /*
              allows debug bundles to gather systemd logs for `netbird*.service`
              this is not ideal for hardening as it grants access to the whole journal, not just own logs
            */
            "systemd-journal"
          ];
        }
      );
    }
    # Hardening section
    (mkIf (hardenedClients != { }) {
      # see https://github.com/systemd/systemd/blob/17f3e91e8107b2b29fe25755651b230bbc81a514/src/resolve/org.freedesktop.resolve1.policy#L43-L43
      # see all actions used at https://github.com/netbirdio/netbird/blob/13e7198046a0d73a9cd91bf8e063fafb3d41885c/client/internal/dns/systemd_linux.go#L29-L32
      security.polkit.extraConfig = mkIf config.services.resolved.enable ''
        // systemd-resolved access for NetBird clients
        polkit.addRule(function(action, subject) {
          var actions = [
            "org.freedesktop.resolve1.revert",
            "org.freedesktop.resolve1.set-default-route",
            "org.freedesktop.resolve1.set-dns-servers",
            "org.freedesktop.resolve1.set-domains",
            "org.freedesktop.resolve1.set-dnssec",
          ];
          var users = ${builtins.toJSON (toHardenedClientList (client: client.user.name))};

          if (actions.indexOf(action.id) >= 0 && users.indexOf(subject.user) >= 0 ) {
            return polkit.Result.YES;
          }
        });
      '';

      systemd.services = mkMerge [
        # netbird services
        (toHardenedClientAttrs (
          client:
          nameValuePair client.service.name (
            mkIf client.hardened {
              serviceConfig = {
                AmbientCapabilities = [
                  # see https://man7.org/linux/man-pages/man7/capabilities.7.html
                  # see https://docs.netbird.io/how-to/installation#running-net-bird-in-docker
                  #
                  # seems to work fine without CAP_SYS_ADMIN and CAP_SYS_RESOURCE
                  # CAP_NET_BIND_SERVICE could be added to allow binding on low ports, but is not required,
                  #  see https://github.com/netbirdio/netbird/pull/1513

                  # failed creating tunnel interface wt-priv: [operation not permitted
                  "CAP_NET_ADMIN"
                  # failed to pull up wgInterface [wt-priv]: failed to create ipv4 raw socket: socket: operation not permitted
                  "CAP_NET_RAW"
                ]
                # required for eBPF filter, used to be subset of CAP_SYS_ADMIN
                ++ optional (versionAtLeast kernel.version "5.8") "CAP_BPF"
                ++ optional (versionOlder kernel.version "5.8") "CAP_SYS_ADMIN"
                ++ optional (
                  client.dns-resolver.address != null && client.dns-resolver.port < 1024
                ) "CAP_NET_BIND_SERVICE";

                Group = client.user.group;
                PrivateTmp = true;
                ProtectHome = "yes";
                ProtectSystem = "strict";
                # settings implied by DynamicUser=true, without actually using it,
                # see https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#DynamicUser=
                RemoveIPC = true;
                RuntimeDirectoryMode = "0750";
                User = client.user.name;
              };
            }
          )
        ))
        # netbird-login services
        (toHardenedClientAttrs (
          client:
          nameValuePair "${client.service.name}-login" (
            mkIf client.hardened {
              serviceConfig = {
                Group = client.user.group;
                PrivateTmp = "disconnected"; # "disconnected" puts /tmp on `tmpfs`
                ProtectHome = "yes";
                ProtectSystem = "strict";
                RemoveIPC = true;
                User = client.user.name;
              };
            }
          )
        ))
      ];

      users.groups = toHardenedClientAttrs (client: nameValuePair client.user.group { });

      users.users = toHardenedClientAttrs (
        client:
        nameValuePair client.user.name {
          group = client.user.group;
          home = client.dir.state;
          isSystemUser = true;
        }
      );
    })
    # Setup Keys login automation
    {
      systemd.services = pipe cfg.clients [
        (filterAttrs (_: client: client.login.enable))
        (mapAttrs' (
          _: client:
          nameValuePair "${client.service.name}-login" {
            after = [ "${client.service.name}.service" ] ++ client.login.systemdDependencies;
            environment.NB_SETUP_KEY_FILE = "%d/setup-key";
            requires = [ "${client.service.name}.service" ] ++ client.login.systemdDependencies;

            script = ''
              set -x

              get_status() {
                '${lib.getExe client.wrapper}' status 2>&1 || :
              }

              main() {
                # grep for `: Connected` as well, as `Connected` appears other
                # places even when not connected, and before NeedsLogin
                until get_status | grep --quiet ': Connected\|NeedsLogin' ; do
                  sleep 1
                done

                if get_status | grep --quiet 'NeedsLogin' ; then
                  # setup key is in $NB_SETUP_KEY_FILE, and is
                  # automatically picked up by the cli
                  '${lib.getExe client.wrapper}' up
                fi
              }

              main "$@"
            '';

            serviceConfig = {
              LoadCredential = [ "setup-key:${client.login.setupKeyFile}" ];
              RemainAfterExit = true;
              Type = "oneshot";
            };

            wantedBy = [ "${client.service.name}.service" ];
          }
        ))
      ];
    }
    # migration & temporary fixups section
    {
      systemd.services = toClientAttrs (
        client:
        nameValuePair client.service.name {
          preStart = ''
            set -eEuo pipefail
            ${optionalString (client.logLevel == "trace" || client.logLevel == "debug") "set -x"}

            PATH="${
              makeBinPath (
                with pkgs;
                [
                  coreutils
                  jq
                  diffutils
                ]
              )
            }:$PATH"
            export ${toShellVars client.environment}

            # merge /etc/${client.dir.baseName}/config.d' into "$NB_CONFIG"
            {
              test -e "$NB_CONFIG" || echo -n '{}' > "$NB_CONFIG"

              # merge config.d with "$NB_CONFIG" into "$NB_CONFIG.new"
              jq -sS 'reduce .[] as $i ({}; . * $i)' \
                "$NB_CONFIG" \
                /etc/${client.dir.baseName}/config.d/*.json \
                > "$NB_CONFIG.new"

              echo "Comparing $NB_CONFIG with $NB_CONFIG.new ..."
              if ! diff <(jq -S <"$NB_CONFIG") "$NB_CONFIG.new" ; then
                echo "Updating $NB_CONFIG ..."
                mv "$NB_CONFIG.new" "$NB_CONFIG"
              else
                echo "Files are the same, not doing anything."
                rm "$NB_CONFIG.new"
              fi
            }
          '';
        }
      );
    }
  ];

  meta.doc = ./netbird.md;

  meta.maintainers = with maintainers; [
    nazarewk
  ];
}
