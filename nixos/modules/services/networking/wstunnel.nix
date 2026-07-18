{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.wstunnel;

  argsFormat = {
    generate = lib.cli.toCommandLineShellGNU { };

    type =
      let
        inherit (lib.types)
          attrsOf
          listOf
          oneOf
          bool
          int
          str
          ;
      in
      attrsOf (oneOf [
        bool
        int
        str
        (listOf str)
      ]);
  };

  hostPortToString = { host, port, ... }: "${host}:${toString port}";

  commonOptions = {
    enable = lib.mkEnableOption "this `wstunnel` instance" // {
      default = true;
    };

    package = lib.mkPackageOption pkgs "wstunnel" { };

    autoStart = lib.mkEnableOption "starting this wstunnel instance automatically" // {
      default = true;
    };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        Environment file to be passed to the systemd service.
        Useful for passing secrets to the service to prevent them from being
        world-readable in the Nix store.
        Note however that the secrets are passed to `wstunnel` through
        the command line, which makes them locally readable for all users of
        the system at runtime.
      '';

      example = "/var/lib/secrets/wstunnelSecrets";
      type = lib.types.nullOr lib.types.path;
    };
  };

  serverSubmodule =
    let
      outerConfig = config;
    in
    { config, ... }:
    let
      certConfig = outerConfig.security.acme.certs.${config.useACMEHost};
    in
    {
      imports = [
        ../../misc/assertions.nix

        (lib.mkRenamedOptionModule
          [
            "enableHTTPS"
          ]
          [
            "listen"
            "enableHTTPS"
          ]
        )
      ]
      ++
        lib.map
          (
            option:
            lib.mkRemovedOptionModule [ option ] ''
              The wstunnel module now uses RFC-42-style settings, please modify your config accordingly
            ''
          )
          [
            "extraArgs"
            "websocketPingInterval"
            "loggingLevel"

            "restrictTo"
            "tlsCertificate"
            "tlsKey"
          ];

      options = commonOptions // {
        listen = lib.mkOption {
          default =
            { config, ... }:
            {
              host = "0.0.0.0";
              port = if config.enableHTTPS then 443 else 80;
            };

          defaultText = lib.literalExpression ''
            { config, ... }:
            {
              host = "0.0.0.0";
              port = if config.enableHTTPS then 443 else 80;
            }
          '';

          description = ''
            Address and port to listen on.
            Setting the port to a value below 1024 will also give the process
            the required `CAP_NET_BIND_SERVICE` capability.
          '';

          type = lib.types.submodule {
            options = {
              enableHTTPS = lib.mkOption {
                default = true;
                description = "Use HTTPS for the tunnel server.";
                type = lib.types.bool;
              };

              host = lib.mkOption {
                description = "The hostname.";
                type = lib.types.str;
              };

              port = lib.mkOption {
                description = "The port.";
                type = lib.types.port;
              };
            };
          };
        };

        settings = lib.mkOption {
          default = { };

          description = ''
            Command line arguments to pass to `wstunnel`.
            Attributes of the form `argName = true;` will be translated to `--argName`,
            and `argName = \"value\"` to `--argName value`.
          '';

          example = {
            "someNewOption" = true;
            "someNewOptionWithValue" = "someValue";
          };

          type = lib.types.submodule {
            options = {
              restrict-to = lib.mkOption {
                default = [ ];

                description = ''
                  Restrictions on the connections that the server will accept.
                  For more flexibility, and the possibility to also allow reverse tunnels,
                  look into the `restrict-config` option that takes a path to a yaml file.
                '';

                example = [
                  {
                    host = "127.0.0.1";
                    port = 51820;
                  }
                ];

                type = lib.types.listOf (
                  lib.types.submodule {
                    options = {
                      host = lib.mkOption {
                        description = "The hostname.";
                        type = lib.types.str;
                      };

                      port = lib.mkOption {
                        description = "The port.";
                        type = lib.types.port;
                      };
                    };
                  }
                );
              };
            };

            freeformType = argsFormat.type;
          };
        };

        useACMEHost = lib.mkOption {
          default = null;

          description = ''
            Use a certificate generated by the NixOS ACME module for the given host.
            Note that this will not generate a new certificate - you will need to do so with `security.acme.certs`.
          '';

          example = "example.com";
          type = lib.types.nullOr lib.types.str;
        };
      };

      config = {
        settings = lib.mkIf (config.useACMEHost != null) {
          tls-certificate = "${certConfig.directory}/fullchain.pem";
          tls-private-key = "${certConfig.directory}/key.pem";
        };
      };
    };

  clientSubmodule =
    { config, ... }:
    {
      imports = [
        ../../misc/assertions.nix
      ]
      ++
        lib.map
          (
            option:
            lib.mkRemovedOptionModule [ option ] ''
              The wstunnel module now uses RFC-42-style settings, please modify your config accordingly
            ''
          )
          [
            "extraArgs"
            "websocketPingInterval"
            "loggingLevel"

            "localToRemote"
            "remoteToLocal"
            "httpProxy"
            "soMark"
            "upgradePathPrefix"
            "tlsSNI"
            "tlsVerifyCertificate"
            "upgradeCredentials"
            "customHeaders"
          ];

      options = commonOptions // {
        addNetBind = lib.mkEnableOption "Whether add CAP_NET_BIND_SERVICE to the tunnel service, this should be enabled if you want to bind port < 1024";

        connectTo = lib.mkOption {
          description = "Server address and port to connect to.";
          example = "https://wstunnel.server.com:8443";
          type = lib.types.str;
        };

        settings = lib.mkOption {
          default = { };

          description = ''
            Command line arguments to pass to `wstunnel`.
            Attributes of the form `argName = true;` will be translated to `--argName`,
            and `argName = \"value\"` to `--argName value`.
          '';

          example = {
            "someNewOption" = true;
            "someNewOptionWithValue" = "someValue";
          };

          type = lib.types.submodule {
            options = {
              http-headers = lib.mkOption {
                default = { };

                description = ''
                  Custom headers to send in the upgrade request
                '';

                example = {
                  "X-Some-Header" = "some-value";
                };

                type = lib.types.coercedTo (lib.types.attrsOf lib.types.str) (lib.mapAttrsToList (
                  n: v: "${n}:${v}"
                )) (lib.types.listOf lib.types.str);
              };
            };

            freeformType = argsFormat.type;
          };
        };
      };
    };

  generateServerUnit = name: serverCfg: {
    name = "wstunnel-server-${name}";

    value =
      let
        certConfig = config.security.acme.certs.${serverCfg.useACMEHost};
      in
      {
        after = [
          "network.target"
          "network-online.target"
        ];

        description = "wstunnel server - ${name}";

        requires = [
          "network.target"
          "network-online.target"
        ];

        serviceConfig = {
          AmbientCapabilities = lib.optionals (serverCfg.listen.port < 1024) [ "CAP_NET_BIND_SERVICE" ];
          DynamicUser = true;
          EnvironmentFile = lib.optional (serverCfg.environmentFile != null) serverCfg.environmentFile;

          ExecStart =
            let
              convertedSettings = serverCfg.settings // {
                restrict-to = lib.map hostPortToString serverCfg.settings.restrict-to;
              };
            in
            ''
              ${lib.getExe serverCfg.package} \
                server \
                ${argsFormat.generate convertedSettings} \
                ${lib.escapeShellArg "${
                  if serverCfg.listen.enableHTTPS then "wss" else "ws"
                }://${hostPortToString serverCfg.listen}"}
            '';

          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          Restart = "on-failure";
          RestartMaxDelaySec = "5min";
          RestartSec = 2;
          RestartSteps = 20;

          RestrictNamespaces = [
            "uts"
            "ipc"
            "pid"
            "user"
            "cgroup"
          ];

          RestrictSUIDSGID = true;
          SupplementaryGroups = lib.optional (serverCfg.useACMEHost != null) certConfig.group;
          Type = "exec";
        };

        wantedBy = lib.optional serverCfg.autoStart "multi-user.target";
      };
  };

  generateClientUnit = name: clientCfg: {
    name = "wstunnel-client-${name}";

    value = {
      after = [
        "network.target"
        "network-online.target"
      ];

      description = "wstunnel client - ${name}";

      requires = [
        "network.target"
        "network-online.target"
      ];

      serviceConfig = {
        AmbientCapabilities =
          (lib.optionals clientCfg.addNetBind [ "CAP_NET_BIND_SERVICE" ])
          ++ (lib.optionals ((clientCfg.settings.socket-so-mark or null) != null) [ "CAP_NET_ADMIN" ]);

        DynamicUser = true;
        EnvironmentFile = lib.optional (clientCfg.environmentFile != null) clientCfg.environmentFile;

        ExecStart = ''
          ${lib.getExe clientCfg.package} \
            client \
            ${argsFormat.generate clientCfg.settings} \
            ${lib.escapeShellArg clientCfg.connectTo}
        '';

        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartMaxDelaySec = "5min";
        RestartSec = 2;
        RestartSteps = 20;

        RestrictNamespaces = [
          "uts"
          "ipc"
          "pid"
          "user"
          "cgroup"
        ];

        RestrictSUIDSGID = true;
        Type = "exec";
      };

      wantedBy = lib.optional clientCfg.autoStart "multi-user.target";
    };
  };
in
{
  options.services.wstunnel = {
    enable = lib.mkEnableOption "wstunnel";

    clients = lib.mkOption {
      default = { };
      description = "`wstunnel` clients to set up.";

      example = {
        "wg-tunnel" = {
          connectTo = "wss://wstunnel.server.com:8443";

          localToRemote = [
            "tcp://1212:google.com:443"
            "tcp://2:n.lan:4?proxy_protocol"
          ];

          remoteToLocal = [
            "socks5://[::1]:1212"
            "unix://wstunnel.sock:g.com:443"
          ];
        };
      };

      type = lib.types.attrsOf (lib.types.submodule clientSubmodule);
    };

    servers = lib.mkOption {
      default = { };
      description = "`wstunnel` servers to set up.";

      example = {
        "wg-tunnel" = {
          listen = {
            enableHTTPS = true;
            host = "0.0.0.0";
            port = 8080;
          };

          settings = {
            restrict-to = [
              {
                host = "127.0.0.1";
                port = 51820;
              }
            ];

            tls-certificate = "/var/lib/secrets/fullchain.pem";
            tls-private-key = "/var/lib/secrets/key.pem";
          };
        };
      };

      type = lib.types.attrsOf (lib.types.submodule serverSubmodule);
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      (lib.mapAttrsToList (name: serverCfg: {
        assertion =
          serverCfg.listen.enableHTTPS
          ->
            (serverCfg.useACMEHost != null)
            || (
              (serverCfg.settings.tls-certificate or null) != null
              && (serverCfg.settings.tls-private-key or null) != null
            );

        message = ''
          If services.wstunnel.servers."${name}".listen.enableHTTPS is set to true, either services.wstunnel.servers."${name}".useACMEHost or both services.wstunnel.servers."${name}".settings.tls-private-key and services.wstunnel.servers."${name}".settings.tls-certificate need to be set.
        '';
      }) cfg.servers)
      ++ (lib.foldlAttrs (
        assertions: _: server:
        assertions ++ server.assertions
      ) [ ] cfg.servers)

      ++ (lib.mapAttrsToList (
        name: clientCfg:
        let
          isListAttrDefined = settings: attr: (settings.${attr} or [ ]) != [ ];
        in
        {
          assertion =
            isListAttrDefined clientCfg.settings "local-to-remote"
            || isListAttrDefined clientCfg.settings "remote-to-local";

          message = ''
            Either one of services.wstunnel.clients."${name}".settings.local-to-remote or services.wstunnel.clients."${name}".settings.remote-to-local must be set.
          '';
        }
      ) cfg.clients)
      ++ (lib.foldlAttrs (
        assertions: _: client:
        assertions ++ client.assertions
      ) [ ] cfg.clients);

    systemd.services =
      (lib.mapAttrs' generateServerUnit (lib.filterAttrs (_: v: v.enable) cfg.servers))
      // (lib.mapAttrs' generateClientUnit (lib.filterAttrs (_: v: v.enable) cfg.clients));

    warnings =
      (lib.foldlAttrs (
        warnings: _: server:
        warnings ++ server.warnings
      ) [ ] cfg.servers)
      ++ (lib.foldlAttrs (
        warnings: _: client:
        warnings ++ client.warnings
      ) [ ] cfg.clients);
  };

  meta.maintainers = with lib.maintainers; [
    pentane
    raylas
    rvdp
    neverbehave
  ];
}
