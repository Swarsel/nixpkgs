{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.tor;
  opt = options.services.tor;
  stateDir = "/var/lib/tor";
  runDir = "/run/tor";
  descriptionGeneric = option: ''
    See [torrc manual](https://2019.www.torproject.org/docs/tor-manual.html.en#${option}).
  '';
  bindsPrivilegedPort =
    lib.any
      (
        p0:
        let
          p1 = if p0 ? "port" then p0.port else p0;
        in
        if p1 == "auto" then
          false
        else
          let
            p2 = if lib.isInt p1 then p1 else lib.toInt p1;
          in
          p1 != null && 0 < p2 && p2 < 1024
      )
      (
        lib.flatten [
          cfg.settings.ORPort
          cfg.settings.DirPort
          cfg.settings.DNSPort
          cfg.settings.ExtORPort
          cfg.settings.HTTPTunnelPort
          cfg.settings.NATDPort
          cfg.settings.SOCKSPort
          cfg.settings.TransPort
        ]
      );
  optionBool =
    optionName:
    lib.mkOption {
      default = null;
      description = (descriptionGeneric optionName);
      type = with lib.types; nullOr bool;
    };
  optionInt =
    optionName:
    lib.mkOption {
      default = null;
      description = (descriptionGeneric optionName);
      type = with lib.types; nullOr int;
    };
  optionString =
    optionName:
    lib.mkOption {
      default = null;
      description = (descriptionGeneric optionName);
      type = with lib.types; nullOr str;
    };
  optionStrings =
    optionName:
    lib.mkOption {
      default = [ ];
      description = (descriptionGeneric optionName);
      type = with lib.types; listOf str;
    };
  optionAddress = lib.mkOption {
    default = null;

    description = ''
      IPv4 or IPv6 (if between brackets) address.
    '';

    example = "0.0.0.0";
    type = with lib.types; nullOr str;
  };
  optionUnix = lib.mkOption {
    default = null;

    description = ''
      Unix domain socket path to use.
    '';

    type = with lib.types; nullOr path;
  };
  optionPort = lib.mkOption {
    default = null;

    type =
      with lib.types;
      nullOr (oneOf [
        port
        (enum [ "auto" ])
      ]);
  };
  optionPorts =
    optionName:
    lib.mkOption {
      default = [ ];
      description = (descriptionGeneric optionName);
      type = with lib.types; listOf port;
    };
  optionIsolablePort =
    with lib.types;
    oneOf [
      port
      (enum [ "auto" ])
      (submodule (
        { config, ... }:
        {
          options = {
            SessionGroup = lib.mkOption {
              default = null;
              type = nullOr int;
            };

            addr = optionAddress;
            flags = optionFlags;
            port = optionPort;
          }
          // lib.genAttrs isolateFlags (
            name:
            lib.mkOption {
              default = false;
              type = types.bool;
            }
          );

          config = {
            flags =
              lib.filter (name: config.${name} == true) isolateFlags
              ++ lib.optional (config.SessionGroup != null) "SessionGroup=${toString config.SessionGroup}";
          };
        }
      ))
    ];
  optionIsolablePorts =
    optionName:
    lib.mkOption {
      default = [ ];
      description = (descriptionGeneric optionName);
      type = with lib.types; either optionIsolablePort (listOf optionIsolablePort);
    };
  isolateFlags = [
    "IsolateClientAddr"
    "IsolateClientProtocol"
    "IsolateDestAddr"
    "IsolateDestPort"
    "IsolateSOCKSAuth"
    "KeepAliveIsolateSOCKSAuth"
  ];
  optionSOCKSPort =
    doConfig:
    let
      flags = [
        "CacheDNS"
        "CacheIPv4DNS"
        "CacheIPv6DNS"
        "GroupWritable"
        "IPv6Traffic"
        "NoDNSRequest"
        "NoIPv4Traffic"
        "NoOnionTraffic"
        "OnionTrafficOnly"
        "PreferIPv6"
        "PreferIPv6Automap"
        "PreferSOCKSNoAuth"
        "UseDNSCache"
        "UseIPv4Cache"
        "UseIPv6Cache"
        "WorldWritable"
      ]
      ++ isolateFlags;
    in
    with lib.types;
    oneOf [
      port
      (submodule (
        { config, ... }:
        {
          options = {
            SessionGroup = lib.mkOption {
              default = null;
              type = nullOr int;
            };

            addr = optionAddress;
            flags = optionFlags;
            port = optionPort;
            unix = optionUnix;
          }
          // lib.genAttrs flags (
            name:
            lib.mkOption {
              default = false;
              type = types.bool;
            }
          );

          config = lib.mkIf doConfig {
            # Only add flags in SOCKSPort to avoid duplicates
            flags =
              lib.filter (name: config.${name} == true) flags
              ++ lib.optional (config.SessionGroup != null) "SessionGroup=${toString config.SessionGroup}";
          };
        }
      ))
    ];
  optionFlags = lib.mkOption {
    default = [ ];
    type = with lib.types; listOf str;
  };
  optionORPort =
    optionName:
    lib.mkOption {
      default = [ ];
      description = (descriptionGeneric optionName);
      example = 443;

      type =
        with lib.types;
        oneOf [
          port
          (enum [ "auto" ])
          (listOf (oneOf [
            port
            (enum [ "auto" ])
            (submodule (
              { config, ... }:
              let
                flags = [
                  "IPv4Only"
                  "IPv6Only"
                  "NoAdvertise"
                  "NoListen"
                ];
              in
              {
                options = {
                  addr = optionAddress;
                  flags = optionFlags;
                  port = optionPort;
                }
                // lib.genAttrs flags (
                  name:
                  lib.mkOption {
                    default = false;
                    type = types.bool;
                  }
                );

                config = {
                  flags = lib.filter (name: config.${name} == true) flags;
                };
              }
            ))
          ]))
        ];
    };
  optionBandwidth =
    optionName:
    lib.mkOption {
      default = null;
      description = (descriptionGeneric optionName);
      type = with lib.types; nullOr (either int str);
    };
  optionPath =
    optionName:
    lib.mkOption {
      default = null;
      description = (descriptionGeneric optionName);
      type = with lib.types; nullOr path;
    };

  mkValueString =
    k: v:
    if v == null then
      ""
    else if lib.isBool v then
      (if v then "1" else "0")
    else if v ? "unix" && v.unix != null then
      "unix:" + v.unix + lib.optionalString (v ? "flags") (" " + lib.concatStringsSep " " v.flags)
    else if v ? "port" && v.port != null then
      lib.optionalString (v ? "addr" && v.addr != null) "${v.addr}:"
      + toString v.port
      + lib.optionalString (v ? "flags") (" " + lib.concatStringsSep " " v.flags)
    else if k == "ServerTransportPlugin" then
      lib.optionalString (v.transports != [ ]) "${lib.concatStringsSep "," v.transports} exec ${v.exec}"
    else if k == "HidServAuth" then
      v.onion + " " + v.auth
    else
      lib.generators.mkValueStringDefault { } v;
  genTorrc =
    settings:
    lib.generators.toKeyValue
      {
        listsAsDuplicateKeys = true;
        mkKeyValue = k: lib.generators.mkKeyValueDefault { mkValueString = mkValueString k; } " " k;
      }
      (
        lib.mapAttrs (
          k: v:
          # Not necessary, but prettier rendering
          if
            lib.elem k [
              "AutomapHostsSuffixes"
              "DirPolicy"
              "ExitPolicy"
              "SocksPolicy"
            ]
            && v != [ ]
          then
            lib.concatStringsSep "," v
          else
            v
        ) (lib.filterAttrs (k: v: !(v == null || v == "")) settings)
      );
  torrc = pkgs.writeText "torrc" (
    genTorrc cfg.settings
    + lib.concatStrings (
      lib.mapAttrsToList (
        name: onion: "HiddenServiceDir ${onion.path}\n" + genTorrc onion.settings
      ) cfg.relay.onionServices
    )
  );
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "tor" "client" "dns" "automapHostsSuffixes" ]
      [ "services" "tor" "settings" "AutomapHostsSuffixes" ]
    )
    (lib.mkRemovedOptionModule [
      "services"
      "tor"
      "client"
      "dns"
      "isolationOptions"
    ] "Use services.tor.settings.DNSPort instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "tor"
      "client"
      "dns"
      "listenAddress"
    ] "Use services.tor.settings.DNSPort instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "tor"
      "client"
      "privoxy"
      "enable"
    ] "Use services.privoxy.enable and services.privoxy.enableTor instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "tor"
      "client"
      "socksIsolationOptions"
    ] "Use services.tor.settings.SOCKSPort instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "tor"
      "client"
      "socksListenAddressFaster"
    ] "Use services.tor.settings.SOCKSPort instead.")
    (lib.mkRenamedOptionModule
      [ "services" "tor" "client" "socksPolicy" ]
      [ "services" "tor" "settings" "SocksPolicy" ]
    )
    (lib.mkRemovedOptionModule [
      "services"
      "tor"
      "client"
      "transparentProxy"
      "isolationOptions"
    ] "Use services.tor.settings.TransPort instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "tor"
      "client"
      "transparentProxy"
      "listenAddress"
    ] "Use services.tor.settings.TransPort instead.")
    (lib.mkRenamedOptionModule
      [ "services" "tor" "controlPort" ]
      [ "services" "tor" "settings" "ControlPort" ]
    )
    (lib.mkRemovedOptionModule [
      "services"
      "tor"
      "extraConfig"
    ] "Please use services.tor.settings instead.")
    (lib.mkRenamedOptionModule
      [ "services" "tor" "hiddenServices" ]
      [ "services" "tor" "relay" "onionServices" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "tor" "relay" "accountingMax" ]
      [ "services" "tor" "settings" "AccountingMax" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "tor" "relay" "accountingStart" ]
      [ "services" "tor" "settings" "AccountingStart" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "tor" "relay" "address" ]
      [ "services" "tor" "settings" "Address" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "tor" "relay" "bandwidthBurst" ]
      [ "services" "tor" "settings" "BandwidthBurst" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "tor" "relay" "bandwidthRate" ]
      [ "services" "tor" "settings" "BandwidthRate" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "tor" "relay" "bridgeTransports" ]
      [ "services" "tor" "settings" "ServerTransportPlugin" "transports" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "tor" "relay" "contactInfo" ]
      [ "services" "tor" "settings" "ContactInfo" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "tor" "relay" "exitPolicy" ]
      [ "services" "tor" "settings" "ExitPolicy" ]
    )
    (lib.mkRemovedOptionModule [
      "services"
      "tor"
      "relay"
      "isBridge"
    ] "Use services.tor.relay.role instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "tor"
      "relay"
      "isExit"
    ] "Use services.tor.relay.role instead.")
    (lib.mkRenamedOptionModule
      [ "services" "tor" "relay" "nickname" ]
      [ "services" "tor" "settings" "Nickname" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "tor" "relay" "port" ]
      [ "services" "tor" "settings" "ORPort" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "tor" "relay" "portSpec" ]
      [ "services" "tor" "settings" "ORPort" ]
    )
  ];

  options = {
    services.tor = {
      enable = lib.mkEnableOption ''
        Tor daemon.
                By default, the daemon is run without
                relay, exit, bridge or client connectivity'';

      package = lib.mkPackageOption pkgs "tor" { };

      client = {
        enable = lib.mkEnableOption ''
          the routing of application connections.
                    You might want to disable this if you plan running a dedicated Tor relay'';

        dns.enable = lib.mkEnableOption "DNS resolver";

        onionServices = lib.mkOption {
          default = { };
          description = (descriptionGeneric "HiddenServiceDir");

          example = {
            "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" = {
              clientAuthorizations = [ "/run/keys/tor/alice.prv.x25519" ];
            };
          };

          type = lib.types.attrsOf (
            lib.types.submodule (
              { ... }:
              {
                options.clientAuthorizations = lib.mkOption {
                  default = [ ];

                  description = ''
                    Clients' authorizations for a v3 onion service,
                    as a list of files containing each one private key, in the format:
                    ```
                    descriptor:x25519:<base32-private-key>
                    ```
                    ${descriptionGeneric "_client_authorization"}
                  '';

                  example = [ "/run/keys/tor/alice.prv.x25519" ];
                  type = with lib.types; listOf path;
                };
              }
            )
          );
        };

        socksListenAddress = lib.mkOption {
          default = {
            IsolateDestAddr = true;
            addr = "127.0.0.1";
            port = 9050;
          };

          description = ''
            Bind to this address to listen for connections from
            Socks-speaking applications.
          '';

          example = {
            IsolateDestAddr = true;
            addr = "192.168.0.1";
            port = 9090;
          };

          type = optionSOCKSPort false;
        };

        transparentProxy.enable = lib.mkEnableOption "transparent proxy";
      };

      controlSocket.enable = lib.mkEnableOption ''
        control socket,
                created in `${runDir}/control`'';

      enableGeoIP =
        lib.mkEnableOption ''
          use of GeoIP databases.
                  Disabling this will disable by-country statistics for bridges and relays
                  and some client and third-party software functionality''
        // {
          default = true;
        };

      obfs4Package = lib.mkPackageOption pkgs "obfs4" { };
      openFirewall = lib.mkEnableOption "opening of the relay port(s) in the firewall";

      relay = {
        enable = lib.mkEnableOption "tor relaying" // {
          description = ''
            Whether to enable relaying of Tor traffic for others.

            See <https://www.torproject.org/docs/tor-doc-relay>
            for details.

            Setting this to true requires setting
            {option}`services.tor.relay.role`
            and
            {option}`services.tor.settings.ORPort`
            options.
          '';
        };

        onionServices = lib.mkOption {
          default = { };

          description = descriptionGeneric "HiddenServiceDir" + ''
            :::{.warning}
            Because `tor.service` runs in its own `RootDirectory=`,
            when using a onion service to reverse-proxy to a Unix socket,
            you need to make that Unix socket available
            within the mount namespace of `tor.service`.

            When you can configure your service to create its socket in `/tmp`,
            this can be done with:
            ```nix
            systemd.services.''${your-service} = {
              unitConfig.JoinsNamespaceOf = [ "tor.service" ];`
              serviceConfig.PrivateTmp = true;
            };
            ```
            Otherwise, you can use:
            ```nix
            systemd.services.tor.serviceConfig.BindPaths = [ "/path/to/your-service/socket/directory" ];
            ```
            but you have to be sure that `/path/to/socket/directory`
            exists before `tor.service` is started
            and is not deleted and recreated between restarts of `your-service`,
            or you'll need to restart `tor.service` to refresh the `BindPaths=`.
            :::
          '';

          example = {
            "example.org/www" = {
              authorizedClients = [
                "descriptor:x25519:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
              ];

              map = [ 80 ];
            };
          };

          type = lib.types.attrsOf (
            lib.types.submodule (
              { config, name, ... }:
              {
                options.authorizeClient = lib.mkOption {
                  default = null;
                  description = (descriptionGeneric "HiddenServiceAuthorizeClient");

                  type = lib.types.nullOr (
                    lib.types.submodule (
                      { ... }:
                      {
                        options = {
                          authType = lib.mkOption {
                            description = ''
                              Either `"basic"` for a general-purpose authorization protocol
                              or `"stealth"` for a less scalable protocol
                              that also hides service activity from unauthorized clients.
                            '';

                            type = lib.types.enum [
                              "basic"
                              "stealth"
                            ];
                          };

                          clientNames = lib.mkOption {
                            description = ''
                              Only clients that are listed here are authorized to access the hidden service.
                              Generated authorization data can be found in {file}`${stateDir}/onion/$name/hostname`.
                              Clients need to put this authorization data in their configuration file using
                              [](#opt-services.tor.settings.HidServAuth).
                            '';

                            type = with lib.types; nonEmptyListOf (strMatching "[A-Za-z0-9+-_]+");
                          };
                        };
                      }
                    )
                  );
                };

                options.authorizedClients = lib.mkOption {
                  default = [ ];

                  description = ''
                    Authorized clients for a v3 onion service,
                    as a list of public key, in the format:
                    ```
                    descriptor:x25519:<base32-public-key>
                    ```
                    ${descriptionGeneric "_client_authorization"}
                  '';

                  example = [ "descriptor:x25519:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" ];
                  type = with lib.types; listOf str;
                };

                options.map = lib.mkOption {
                  apply = map (
                    v:
                    if lib.isInt v then
                      {
                        port = v;
                        target = null;
                      }
                    else
                      v
                  );

                  description = (descriptionGeneric "HiddenServicePort");

                  example = [
                    {
                      port = 9000;

                      target = {
                        addr = "127.0.0.1";
                        port = 9123;
                      };
                    }
                  ];

                  type =
                    with lib.types;
                    listOf (oneOf [
                      port
                      (submodule (
                        { ... }:
                        {
                          options = {
                            port = optionPort;

                            target = lib.mkOption {
                              default = null;

                              type = nullOr (
                                submodule (
                                  { ... }:
                                  {
                                    options = {
                                      addr = optionAddress;
                                      port = optionPort;
                                      unix = optionUnix;
                                    };
                                  }
                                )
                              );
                            };
                          };
                        }
                      ))
                    ]);
                };

                options.path = lib.mkOption {
                  description = ''
                    Path where to store the data files of the hidden service.
                    If the {option}`secretKey` is null
                    this defaults to `${stateDir}/onion/$onion`,
                    otherwise to `${runDir}/onion/$onion`.
                  '';

                  type = lib.types.path;
                };

                options.secretKey = lib.mkOption {
                  default = null;

                  description = ''
                    Secret key of the onion service.
                    If null, Tor reuses any preexisting secret key (in {option}`path`)
                    or generates a new one.
                    The associated public key and hostname are deterministically regenerated
                    from this file if they do not exist.
                  '';

                  example = "/run/keys/tor/onion/expyuzz4wqqyqhjn/hs_ed25519_secret_key";
                  type = with lib.types; nullOr path;
                };

                options.settings = lib.mkOption {
                  default = { };

                  description = ''
                    Settings of the onion service.
                    ${descriptionGeneric "_hidden_service_options"}
                  '';

                  type = lib.types.submodule {
                    options.HiddenServiceAllowUnknownPorts = optionBool "HiddenServiceAllowUnknownPorts";
                    options.HiddenServiceDirGroupReadable = optionBool "HiddenServiceDirGroupReadable";

                    options.HiddenServiceExportCircuitID = lib.mkOption {
                      default = null;
                      description = (descriptionGeneric "HiddenServiceExportCircuitID");
                      type = with lib.types; nullOr (enum [ "haproxy" ]);
                    };

                    options.HiddenServiceMaxStreams = lib.mkOption {
                      default = null;
                      description = (descriptionGeneric "HiddenServiceMaxStreams");
                      type = with lib.types; nullOr ints.u16;
                    };

                    options.HiddenServiceMaxStreamsCloseCircuit = optionBool "HiddenServiceMaxStreamsCloseCircuit";

                    options.HiddenServiceNumIntroductionPoints = lib.mkOption {
                      default = null;
                      description = (descriptionGeneric "HiddenServiceNumIntroductionPoints");
                      type = with lib.types; nullOr (ints.between 0 20);
                    };

                    options.HiddenServiceSingleHopMode = optionBool "HiddenServiceSingleHopMode";
                    options.RendPostPeriod = optionString "RendPostPeriod";

                    freeformType =
                      with lib.types;
                      (attrsOf (
                        nullOr (oneOf [
                          str
                          int
                          bool
                          (listOf str)
                        ])
                      ))
                      // {
                        description = "settings option";
                      };
                  };
                };

                options.version = lib.mkOption {
                  default = null;
                  description = (descriptionGeneric "HiddenServiceVersion");

                  type =
                    with lib.types;
                    nullOr (enum [
                      2
                      3
                    ]);
                };

                config = {
                  path = lib.mkDefault ((if config.secretKey == null then stateDir else runDir) + "/onion/${name}");

                  settings.HiddenServiceAuthorizeClient =
                    if config.authorizeClient != null then
                      config.authorizeClient.authType + " " + lib.concatStringsSep "," config.authorizeClient.clientNames
                    else
                      null;

                  settings.HiddenServicePort = map (
                    p: mkValueString "" p.port + " " + mkValueString "" p.target
                  ) config.map;

                  settings.HiddenServiceVersion = config.version;
                };
              }
            )
          );
        };

        role = lib.mkOption {
          description = ''
            Your role in Tor network. There're several options:

            - `exit`:
              An exit relay. This allows Tor users to access regular
              Internet services through your public IP.

              You can specify which services Tor users may access via
              your exit relay using {option}`settings.ExitPolicy` option.

            - `relay`:
              Regular relay. This allows Tor users to relay onion
              traffic to other Tor nodes, but not to public
              Internet.

              See
              <https://www.torproject.org/docs/tor-doc-relay.html.en>
              for more info.

            - `bridge`:
              Regular bridge. Works like a regular relay, but
              doesn't list you in the public relay directory and
              hides your Tor node behind obfs4proxy.

              Using this option will make Tor advertise your bridge
              to users through various mechanisms like
              <https://bridges.torproject.org/>, though.

              See <https://www.torproject.org/docs/bridges.html.en>
              for more info.

            - `private-bridge`:
              Private bridge. Works like regular bridge, but does
              not advertise your node in any way.

              Using this role means that you won't contribute to Tor
              network in any way unless you advertise your node
              yourself in some way.

              Use this if you want to run a private bridge, for
              example because you'll give out your bridge addr
              manually to your friends.

              Switching to this role after measurable time in
              "bridge" role is pretty useless as some Tor users
              would have learned about your node already. In the
              latter case you can still change
              {option}`port` option.

              See <https://www.torproject.org/docs/bridges.html.en>
              for more info.

            ::: {.important}
            Running an exit relay may expose you to abuse
            complaints. See
            <https://www.torproject.org/faq.html.en#ExitPolicies>
            for more info.
            :::

            ::: {.important}
            Note that some misconfigured and/or disrespectful
            towards privacy sites will block you even if your
            relay is not an exit relay. That is, just being listed
            in a public relay directory can have unwanted
            consequences.

            Which means you might not want to use
            this role if you browse public Internet from the same
            network as your relay, unless you want to write
            e-mails to those sites (you should!).
            :::

            ::: {.important}
            WARNING: THE FOLLOWING PARAGRAPH IS NOT LEGAL ADVICE.
            Consult with your lawyer when in doubt.

            The `bridge` role should be safe to use in most situations
            (unless the act of forwarding traffic for others is
            a punishable offence under your local laws, which
            would be pretty insane as it would make ISP illegal).
            :::
          '';

          type = lib.types.enum [
            "exit"
            "relay"
            "bridge"
            "private-bridge"
          ];
        };
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          See [torrc manual](https://2019.www.torproject.org/docs/tor-manual.html.en)
          for documentation.
        '';

        type = lib.types.submodule {
          options.AccountingMax = optionBandwidth "AccountingMax";
          options.AccountingStart = optionString "AccountingStart";
          options.Address = optionString "Address";
          options.AssumeReachable = optionBool "AssumeReachable";
          options.AuthDirHasIPv6Connectivity = optionBool "AuthDirHasIPv6Connectivity";
          options.AuthDirListBadExits = optionBool "AuthDirListBadExits";
          options.AuthDirPinKeys = optionBool "AuthDirPinKeys";
          options.AuthDirSharedRandomness = optionBool "AuthDirSharedRandomness";
          options.AuthDirTestEd25519LinkKeys = optionBool "AuthDirTestEd25519LinkKeys";
          options.AuthoritativeDirectory = optionBool "AuthoritativeDirectory";
          options.AutomapHostsOnResolve = optionBool "AutomapHostsOnResolve";

          options.AutomapHostsSuffixes = optionStrings "AutomapHostsSuffixes" // {
            default = [
              ".onion"
              ".exit"
            ];

            example = [ ".onion" ];
          };

          options.BandwidthBurst = optionBandwidth "BandwidthBurst";
          options.BandwidthRate = optionBandwidth "BandwidthRate";
          options.BridgeAuthoritativeDir = optionBool "BridgeAuthoritativeDir";
          options.BridgeRecordUsageByCountry = optionBool "BridgeRecordUsageByCountry";

          options.BridgeRelay = optionBool "BridgeRelay" // {
            default = false;
          };

          options.CacheDirectory = optionPath "CacheDirectory";
          options.CacheDirectoryGroupReadable = optionBool "CacheDirectoryGroupReadable"; # default is null and like "auto"
          options.CellStatistics = optionBool "CellStatistics";
          options.ClientAutoIPv6ORPort = optionBool "ClientAutoIPv6ORPort";
          options.ClientDNSRejectInternalAddresses = optionBool "ClientDNSRejectInternalAddresses";

          options.ClientOnionAuthDir = lib.mkOption {
            default = null;
            description = (descriptionGeneric "ClientOnionAuthDir");
            type = with lib.types; nullOr path;
          };

          options.ClientPreferIPv6DirPort = optionBool "ClientPreferIPv6DirPort"; # default is null and like "auto"
          options.ClientPreferIPv6ORPort = optionBool "ClientPreferIPv6ORPort"; # default is null and like "auto"
          options.ClientRejectInternalAddresses = optionBool "ClientRejectInternalAddresses";
          options.ClientUseIPv4 = optionBool "ClientUseIPv4";
          options.ClientUseIPv6 = optionBool "ClientUseIPv6";
          options.ConnDirectionStatistics = optionBool "ConnDirectionStatistics";
          options.ConstrainedSockets = optionBool "ConstrainedSockets";
          options.ContactInfo = optionString "ContactInfo";

          options.ControlPort = lib.mkOption {
            default = [ ];
            description = (descriptionGeneric "ControlPort");
            example = [ { port = 9051; } ];

            type =
              with lib.types;
              oneOf [
                port
                (enum [ "auto" ])
                (listOf (oneOf [
                  port
                  (enum [ "auto" ])
                  (submodule (
                    { config, ... }:
                    let
                      flags = [
                        "GroupWritable"
                        "RelaxDirModeCheck"
                        "WorldWritable"
                      ];
                    in
                    {
                      options = {
                        addr = optionAddress;
                        flags = optionFlags;
                        port = optionPort;
                        unix = optionUnix;
                      }
                      // lib.genAttrs flags (
                        name:
                        lib.mkOption {
                          default = false;
                          type = types.bool;
                        }
                      );

                      config = {
                        flags = lib.filter (name: config.${name} == true) flags;
                      };
                    }
                  ))
                ]))
              ];
          };

          options.ControlPortFileGroupReadable = optionBool "ControlPortFileGroupReadable";
          options.ControlPortWriteToFile = optionPath "ControlPortWriteToFile";
          options.ControlSocket = optionPath "ControlSocket";
          options.ControlSocketsGroupWritable = optionBool "ControlSocketsGroupWritable";
          options.CookieAuthFile = optionPath "CookieAuthFile";
          options.CookieAuthFileGroupReadable = optionBool "CookieAuthFileGroupReadable";
          options.CookieAuthentication = optionBool "CookieAuthentication";
          options.DNSPort = optionIsolablePorts "DNSPort";

          options.DataDirectory = optionPath "DataDirectory" // {
            default = stateDir;
          };

          options.DataDirectoryGroupReadable = optionBool "DataDirectoryGroupReadable";
          options.DirAllowPrivateAddresses = optionBool "DirAllowPrivateAddresses";
          options.DirCache = optionBool "DirCache";

          options.DirPolicy = lib.mkOption {
            default = [ ];
            description = (descriptionGeneric "DirPolicy");
            example = [ "accept *:*" ];
            type = with lib.types; listOf str;
          };

          options.DirPort = optionORPort "DirPort";
          options.DirPortFrontPage = optionPath "DirPortFrontPage";
          options.DirReqStatistics = optionBool "DirReqStatistics";
          options.DisableAllSwap = optionBool "DisableAllSwap";
          options.DisableDebuggerAttachment = optionBool "DisableDebuggerAttachment";
          options.DisableNetwork = optionBool "DisableNetwork";
          options.DisableOOSCheck = optionBool "DisableOOSCheck";
          options.DoSCircuitCreationEnabled = optionBool "DoSCircuitCreationEnabled";
          options.DoSConnectionEnabled = optionBool "DoSConnectionEnabled"; # default is null and like "auto"
          options.DoSRefuseSingleHopClientRendezvous = optionBool "DoSRefuseSingleHopClientRendezvous";
          options.DormantCanceledByStartup = optionBool "DormantCanceledByStartup";
          options.DormantOnFirstStartup = optionBool "DormantOnFirstStartup";
          options.DormantTimeoutDisabledByIdleStreams = optionBool "DormantTimeoutDisabledByIdleStreams";
          options.DownloadExtraInfo = optionBool "DownloadExtraInfo";
          options.EnforceDistinctSubnets = optionBool "EnforceDistinctSubnets";
          options.EntryStatistics = optionBool "EntryStatistics";

          options.ExitPolicy = optionStrings "ExitPolicy" // {
            default = [ "reject *:*" ];
            example = [ "accept *:*" ];
          };

          options.ExitPolicyRejectLocalInterfaces = optionBool "ExitPolicyRejectLocalInterfaces";
          options.ExitPolicyRejectPrivate = optionBool "ExitPolicyRejectPrivate";
          options.ExitPortStatistics = optionBool "ExitPortStatistics";
          options.ExitRelay = optionBool "ExitRelay"; # default is null and like "auto"

          options.ExtORPort = lib.mkOption {
            apply = p: if lib.isInt p || lib.isString p then { port = p; } else p;
            default = null;
            description = (descriptionGeneric "ExtORPort");

            type =
              with lib.types;
              nullOr (oneOf [
                port
                (enum [ "auto" ])
                (submodule (
                  { ... }:
                  {
                    options = {
                      addr = optionAddress;
                      port = optionPort;
                    };
                  }
                ))
              ]);
          };

          options.ExtORPortCookieAuthFile = optionPath "ExtORPortCookieAuthFile";
          options.ExtORPortCookieAuthFileGroupReadable = optionBool "ExtORPortCookieAuthFileGroupReadable";
          options.ExtendAllowPrivateAddresses = optionBool "ExtendAllowPrivateAddresses";
          options.ExtraInfoStatistics = optionBool "ExtraInfoStatistics";
          options.FascistFirewall = optionBool "FascistFirewall";
          options.FetchDirInfoEarly = optionBool "FetchDirInfoEarly";
          options.FetchDirInfoExtraEarly = optionBool "FetchDirInfoExtraEarly";
          options.FetchHidServDescriptors = optionBool "FetchHidServDescriptors";
          options.FetchServerDescriptors = optionBool "FetchServerDescriptors";
          options.FetchUselessDescriptors = optionBool "FetchUselessDescriptors";
          options.GeoIPFile = optionPath "GeoIPFile";
          options.GeoIPv6File = optionPath "GeoIPv6File";
          options.GuardfractionFile = optionPath "GuardfractionFile";
          options.HSLayer2Nodes = optionStrings "HSLayer2Nodes";
          options.HSLayer3Nodes = optionStrings "HSLayer3Nodes";
          options.HTTPTunnelPort = optionIsolablePorts "HTTPTunnelPort";

          options.HidServAuth = lib.mkOption {
            default = [ ];
            description = (descriptionGeneric "HidServAuth");

            example = [
              {
                auth = "xxxxxxxxxxxxxxxxxxxxxx";
                onion = "xxxxxxxxxxxxxxxx.onion";
              }
            ];

            type =
              with lib.types;
              listOf (oneOf [
                (submodule {
                  options = {
                    auth = lib.mkOption {
                      description = "Authentication cookie.";
                      type = strMatching "[A-Za-z0-9+/]{22}";
                    };

                    onion = lib.mkOption {
                      description = "Onion address.";
                      example = "xxxxxxxxxxxxxxxx.onion";
                      type = strMatching "[a-z2-7]{16}\\.onion";
                    };
                  };
                })
              ]);
          };

          options.HiddenServiceNonAnonymousMode = optionBool "HiddenServiceNonAnonymousMode";
          options.HiddenServiceStatistics = optionBool "HiddenServiceStatistics";
          options.IPv6Exit = optionBool "IPv6Exit";
          options.KeyDirectory = optionPath "KeyDirectory";
          options.KeyDirectoryGroupReadable = optionBool "KeyDirectoryGroupReadable";
          options.LogMessageDomains = optionBool "LogMessageDomains";
          options.LongLivedPorts = optionPorts "LongLivedPorts";
          options.MainloopStats = optionBool "MainloopStats";
          options.MaxAdvertisedBandwidth = optionBandwidth "MaxAdvertisedBandwidth";
          options.MaxCircuitDirtiness = optionInt "MaxCircuitDirtiness";
          options.MaxClientCircuitsPending = optionInt "MaxClientCircuitsPending";
          options.NATDPort = optionIsolablePorts "NATDPort";
          options.NewCircuitPeriod = optionInt "NewCircuitPeriod";

          options.Nickname = lib.mkOption {
            default = null;
            description = (descriptionGeneric "Nickname");
            type = with lib.types; nullOr (strMatching "^[a-zA-Z0-9]{1,19}$");
          };

          options.ORPort = optionORPort "ORPort";
          options.OfflineMasterKey = optionBool "OfflineMasterKey";
          options.OptimisticData = optionBool "OptimisticData"; # default is null and like "auto"
          options.PaddingStatistics = optionBool "PaddingStatistics";
          options.PerConnBWBurst = optionBandwidth "PerConnBWBurst";
          options.PerConnBWRate = optionBandwidth "PerConnBWRate";
          options.PidFile = optionPath "PidFile";
          options.ProtocolWarnings = optionBool "ProtocolWarnings";
          options.PublishHidServDescriptors = optionBool "PublishHidServDescriptors";

          options.PublishServerDescriptor = lib.mkOption {
            default = null;
            description = (descriptionGeneric "PublishServerDescriptor");

            type =
              with lib.types;
              nullOr (enum [
                false
                true
                0
                1
                "0"
                "1"
                "v3"
                "bridge"
              ]);
          };

          options.ReachableAddresses = optionStrings "ReachableAddresses";
          options.ReachableDirAddresses = optionStrings "ReachableDirAddresses";
          options.ReachableORAddresses = optionStrings "ReachableORAddresses";
          options.ReducedExitPolicy = optionBool "ReducedExitPolicy";
          options.RefuseUnknownExits = optionBool "RefuseUnknownExits"; # default is null and like "auto"
          options.RejectPlaintextPorts = optionPorts "RejectPlaintextPorts";
          options.RelayBandwidthBurst = optionBandwidth "RelayBandwidthBurst";
          options.RelayBandwidthRate = optionBandwidth "RelayBandwidthRate";

          options.SOCKSPort = lib.mkOption {
            default = lib.optionals cfg.settings.HiddenServiceNonAnonymousMode [ { port = 0; } ];

            defaultText = lib.literalExpression ''
              if config.${opt.settings}.HiddenServiceNonAnonymousMode == true
              then [ { port = 0; } ]
              else [ ]
            '';

            description = (descriptionGeneric "SOCKSPort");
            example = [ { port = 9090; } ];
            type = lib.types.listOf (optionSOCKSPort true);
          };

          #options.RunAsDaemon
          options.Sandbox = optionBool "Sandbox";
          options.ServerDNSAllowBrokenConfig = optionBool "ServerDNSAllowBrokenConfig";
          options.ServerDNSAllowNonRFC953Hostnames = optionBool "ServerDNSAllowNonRFC953Hostnames";
          options.ServerDNSDetectHijacking = optionBool "ServerDNSDetectHijacking";
          options.ServerDNSRandomizeCase = optionBool "ServerDNSRandomizeCase";
          options.ServerDNSResolvConfFile = optionPath "ServerDNSResolvConfFile";
          options.ServerDNSSearchDomains = optionBool "ServerDNSSearchDomains";

          options.ServerTransportPlugin = lib.mkOption {
            default = null;
            description = (descriptionGeneric "ServerTransportPlugin");

            type =
              with lib.types;
              nullOr (
                submodule (
                  { ... }:
                  {
                    options = {
                      exec = lib.mkOption {
                        description = "Command of pluggable transport.";
                        type = types.str;
                      };

                      transports = lib.mkOption {
                        description = "List of pluggable transports.";

                        example = [
                          "obfs2"
                          "obfs3"
                          "obfs4"
                          "scramblesuit"
                        ];

                        type = listOf str;
                      };
                    };
                  }
                )
              );
          };

          options.ShutdownWaitLength = lib.mkOption {
            default = 30;
            description = (descriptionGeneric "ShutdownWaitLength");
            type = lib.types.int;
          };

          options.SocksPolicy = optionStrings "SocksPolicy" // {
            example = [ "accept *:*" ];
          };

          options.TestingTorNetwork = optionBool "TestingTorNetwork";
          options.TransPort = optionIsolablePorts "TransPort";

          options.TransProxyType = lib.mkOption {
            default = null;
            description = (descriptionGeneric "TransProxyType");

            type =
              with lib.types;
              nullOr (enum [
                "default"
                "TPROXY"
                "ipfw"
                "pf-divert"
              ]);
          };

          #options.TruncateLogFile
          options.UnixSocksGroupWritable = optionBool "UnixSocksGroupWritable";
          options.UseDefaultFallbackDirs = optionBool "UseDefaultFallbackDirs";
          options.UseMicrodescriptors = optionBool "UseMicrodescriptors";
          options.V3AuthUseLegacyKey = optionBool "V3AuthUseLegacyKey";
          options.V3AuthoritativeDirectory = optionBool "V3AuthoritativeDirectory";
          options.VersioningAuthoritativeDirectory = optionBool "VersioningAuthoritativeDirectory";
          options.VirtualAddrNetworkIPv4 = optionString "VirtualAddrNetworkIPv4";
          options.VirtualAddrNetworkIPv6 = optionString "VirtualAddrNetworkIPv6";
          options.WarnPlaintextPorts = optionPorts "WarnPlaintextPorts";

          freeformType =
            with lib.types;
            (attrsOf (
              nullOr (oneOf [
                str
                int
                bool
                (listOf str)
              ])
            ))
            // {
              description = "settings option";
            };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts =
        lib.concatMap
          (
            o:
            if lib.isInt o && o > 0 then
              [ o ]
            else
              lib.optionals (o ? "port" && lib.isInt o.port && o.port > 0) [ o.port ]
          )
          (
            lib.flatten [
              cfg.settings.ORPort
              cfg.settings.DirPort
            ]
          );
    };

    services.tor.settings = lib.mkMerge [
      (lib.mkIf cfg.enableGeoIP {
        GeoIPFile = "${cfg.package.geoip}/share/tor/geoip";
        GeoIPv6File = "${cfg.package.geoip}/share/tor/geoip6";
      })
      (lib.mkIf cfg.controlSocket.enable {
        ControlPort = [
          {
            GroupWritable = true;
            RelaxDirModeCheck = true;
            unix = runDir + "/control";
          }
        ];
      })
      (lib.mkIf cfg.relay.enable (
        lib.optionalAttrs (cfg.relay.role != "exit") {
          ExitPolicy = lib.mkForce [ "reject *:*" ];
        }
        //
          lib.optionalAttrs
            (lib.elem cfg.relay.role [
              "bridge"
              "private-bridge"
            ])
            {
              BridgeRelay = true;
              ExtORPort.port = lib.mkDefault "auto";
              ServerTransportPlugin.exec = lib.mkDefault "${lib.getExe cfg.obfs4Package} managed";
              ServerTransportPlugin.transports = lib.mkDefault [ "obfs4" ];
            }
        // lib.optionalAttrs (cfg.relay.role == "private-bridge") {
          ExtraInfoStatistics = false;
          PublishServerDescriptor = false;
        }
      ))
      (lib.mkIf (!cfg.relay.enable) {
        # Avoid surprises when leaving ORPort/DirPort configurations in cfg.settings,
        # because it would still enable Tor as a relay,
        # which can trigger all sort of problems when not carefully done,
        # like the blocklisting of the machine's IP addresses
        # by some hosting providers...
        DirPort = lib.mkForce [ ];
        ORPort = lib.mkForce [ ];
        PublishServerDescriptor = lib.mkForce false;
      })
      (lib.mkIf (!cfg.client.enable) {
        # Make sure application connections via SOCKS are disabled
        # when services.tor.client.enable is false
        SOCKSPort = lib.mkForce [ 0 ];
      })
      (lib.mkIf cfg.client.enable (
        {
          SOCKSPort = [ cfg.client.socksListenAddress ];
        }
        // lib.optionalAttrs cfg.client.transparentProxy.enable {
          TransPort = [
            {
              addr = "127.0.0.1";
              port = 9040;
            }
          ];
        }
        // lib.optionalAttrs cfg.client.dns.enable {
          AutomapHostsOnResolve = true;

          DNSPort = [
            {
              addr = "127.0.0.1";
              port = 9053;
            }
          ];
        }
        //
          lib.optionalAttrs
            (lib.flatten (lib.mapAttrsToList (n: o: o.clientAuthorizations) cfg.client.onionServices) != [ ])
            {
              ClientOnionAuthDir = runDir + "/ClientOnionAuthDir";
            }
      ))
    ];

    systemd.services.tor = {
      after = [ "network.target" ];
      description = "Tor Daemon";
      documentation = [ "man:tor(8)" ];
      path = [ cfg.package ];
      restartTriggers = [ torrc ];

      serviceConfig = {
        AmbientCapabilities = [ "" ] ++ lib.optional bindsPrivilegedPort "CAP_NET_BIND_SERVICE";

        BindReadOnlyPaths = [
          "/etc"
        ]
        ++ lib.optional (!config.systemd.services.tor.confinement.enable) builtins.storeDir
        ++ lib.optionals config.services.resolved.enable [
          "/run/systemd/resolve/stub-resolv.conf"
          "/run/systemd/resolve/resolv.conf"
        ];

        CapabilityBoundingSet = [ "" ] ++ lib.optional bindsPrivilegedPort "CAP_NET_BIND_SERVICE";
        # ProtectClock= adds DeviceAllow=char-rtc r
        DeviceAllow = "";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${cfg.package}/bin/tor -f ${torrc}";

        ExecStartPre = [
          "${cfg.package}/bin/tor -f ${torrc} --verify-config"
          # DOC: Appendix G of https://spec.torproject.org/rend-spec-v3
          (
            "+"
            + pkgs.writeShellScript "ExecStartPre" (
              lib.concatStringsSep "\n" (
                lib.flatten (
                  [ "set -eu" ]
                  ++ lib.mapAttrsToList (
                    name: onion:
                    lib.optional (onion.authorizedClients != [ ]) ''
                      rm -rf ${lib.escapeShellArg onion.path}/authorized_clients
                      install -d -o tor -g tor -m 0700 ${lib.escapeShellArg onion.path} ${lib.escapeShellArg onion.path}/authorized_clients
                    ''
                    ++ lib.imap0 (i: pubKey: ''
                      echo ${pubKey} |
                      install -o tor -g tor -m 0400 /dev/stdin ${lib.escapeShellArg onion.path}/authorized_clients/${toString i}.auth
                    '') onion.authorizedClients
                    ++ lib.optional (onion.secretKey != null) ''
                      install -d -o tor -g tor -m 0700 ${lib.escapeShellArg onion.path}
                      key="$(cut -f1 -d: ${lib.escapeShellArg onion.secretKey} | head -1)"
                      case "$key" in
                       ("== ed25519v"*"-secret")
                        install -o tor -g tor -m 0400 ${lib.escapeShellArg onion.secretKey} ${lib.escapeShellArg onion.path}/hs_ed25519_secret_key;;
                       (*) echo >&2 "NixOS does not (yet) support secret key type for onion: ${name}"; exit 1;;
                      esac
                    ''
                  ) cfg.relay.onionServices
                  ++ lib.mapAttrsToList (
                    name: onion:
                    lib.imap0 (
                      i: prvKeyPath:
                      let
                        hostname = lib.removeSuffix ".onion" name;
                      in
                      ''
                        printf "%s:" ${lib.escapeShellArg hostname} | cat - ${lib.escapeShellArg prvKeyPath} |
                        install -o tor -g tor -m 0700 /dev/stdin \
                         ${runDir}/ClientOnionAuthDir/${lib.escapeShellArg hostname}.${toString i}.auth_private
                      ''
                    ) onion.clientAuthorizations
                  ) cfg.client.onionServices
                )
              )
            )
          )
        ];

        Group = "tor";
        KillSignal = "SIGINT";
        LimitNOFILE = 32768;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateNetwork = lib.mkDefault false;
        PrivateTmp = true;
        # Tor cannot currently bind privileged port when PrivateUsers=true,
        # see https://gitlab.torproject.org/legacy/trac/-/issues/20930
        PrivateUsers = !bindsPrivilegedPort;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        # The following options are only to optimize:
        # systemd-analyze security tor
        RootDirectory = runDir + "/root";
        RootDirectoryStartOnly = true;

        RuntimeDirectory = [
          # g+x allows access to the control socket
          "tor"
          "tor/root"
          # g+x can't be removed in ExecStart=, but will be removed by Tor
          "tor/ClientOnionAuthDir"
        ];

        RuntimeDirectoryMode = "0710";

        StateDirectory = [
          "tor"
          "tor/onion"
        ]
        ++ lib.flatten (
          lib.mapAttrsToList (
            name: onion: lib.optional (onion.secretKey == null) "tor/onion/${name}"
          ) cfg.relay.onionServices
        );

        StateDirectoryMode = "0700";
        SystemCallArchitectures = "native";

        # See also the finer but experimental option settings.Sandbox
        SystemCallFilter = [
          "@system-service"
          # Groups in @system-service which do not contain a syscall listed by:
          # perf stat -x, 2>perf.log -e 'syscalls:sys_enter_*' tor
          # in tests, and seem likely not necessary for tor.
          "~@aio"
          "~@chown"
          "~@keyring"
          "~@memlock"
          "~@resources"
          "~@setuid"
          "~@timer"
        ];

        TimeoutSec = cfg.settings.ShutdownWaitLength + 30; # Wait a bit longer than ShutdownWaitLength before actually timing out
        Type = "simple";
        #InaccessiblePaths = [ "-+${runDir}/root" ];
        UMask = "0066";
        User = "tor";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.tor.gid = config.ids.gids.tor;

    users.users.tor = {
      createHome = true;
      description = "Tor Daemon User";
      group = "tor";
      home = stateDir;
      uid = config.ids.uids.tor;
    };

    # Not sure if `cfg.relay.role == "private-bridge"` helps as tor
    # sends a lot of stats
    warnings =
      lib.optional
        (
          cfg.settings.BridgeRelay
          && lib.flatten (lib.mapAttrsToList (n: o: o.map) cfg.relay.onionServices) != [ ]
        )
        ''
          Running Tor hidden services on a public relay makes the
          presence of hidden services visible through simple statistical
          analysis of publicly available data.
          See https://trac.torproject.org/projects/tor/ticket/8742

          You can safely ignore this warning if you don't intend to
          actually hide your hidden services. In either case, you can
          always create a container/VM with a separate Tor daemon instance.
        ''
      ++ lib.flatten (
        lib.mapAttrsToList (
          n: o:
          lib.optionals (o.settings.HiddenServiceVersion == 2) [
            (lib.optional (o.settings.HiddenServiceExportCircuitID != null) ''
              HiddenServiceExportCircuitID is used in the HiddenService: ${n}
              but this option is only for v3 hidden services.
            '')
          ]
          ++ lib.optionals (o.settings.HiddenServiceVersion != 2) [
            (lib.optional (o.settings.HiddenServiceAuthorizeClient != null) ''
              HiddenServiceAuthorizeClient is used in the HiddenService: ${n}
              but this option is only for v2 hidden services.
            '')
            (lib.optional (o.settings.RendPostPeriod != null) ''
              RendPostPeriod is used in the HiddenService: ${n}
              but this option is only for v2 hidden services.
            '')
          ]
        ) cfg.relay.onionServices
      );
  };

  meta.maintainers = with lib.maintainers; [ julm ];
}
