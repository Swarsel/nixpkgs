{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.radicle;

  json = pkgs.formats.json { };

  env = rec {
    # rad fails if it cannot stat $HOME/.gitconfig
    HOME = "/var/lib/radicle";
    RAD_HOME = HOME;
  };

  credentials = {
    privateKey = "dev.radicle.node.secret";
    privateKeyPassphrase = "dev.radicle.node.passphrase";
  };

  # Convenient wrapper to run `rad` in the namespaces of `radicle-node.service`
  rad-system = pkgs.writeShellScriptBin "rad-system" ''
    set -o allexport
    ${lib.toShellVars env}
    # Note that --env is not used to preserve host's envvars like $TERM
    exec ${lib.getExe' pkgs.util-linux "nsenter"} -a \
      -t "$(${lib.getExe' config.systemd.package "systemctl"} show -P MainPID radicle-node.service)" \
      -S "$(${lib.getExe' config.systemd.package "systemctl"} show -P UID radicle-node.service)" \
      -G "$(${lib.getExe' config.systemd.package "systemctl"} show -P GID radicle-node.service)" \
      ${lib.getExe' cfg.package "rad"} "$@"
  '';

  commonServiceConfig = serviceName: {
    after = [
      "network.target"
      "network-online.target"
    ];

    confinement = {
      enable = true;
      mode = "full-apivfs";

      packages = [
        pkgs.gitMinimal
        cfg.package
        pkgs.iana-etc
        (lib.getLib pkgs.nss)
        pkgs.tzdata
      ];
    };

    documentation = [
      "https://radicle.dev/guides/seeder"
    ];

    environment = env // {
      RUST_LOG = lib.mkDefault "info";
    };

    path = [
      pkgs.gitMinimal
    ];

    requires = [
      "network-online.target"
    ];

    serviceConfig = lib.mkMerge [
      {
        BindReadOnlyPaths = [
          "${cfg.configFile}:${env.RAD_HOME}/config.json"
          "${
            if lib.types.path.check cfg.publicKey then
              cfg.publicKey
            else
              pkgs.writeText "radicle.pub" cfg.publicKey
          }:${env.RAD_HOME}/keys/radicle.pub"
          "${config.security.pki.caBundle}:/etc/ssl/certs/ca-certificates.crt"
        ];

        Group = config.users.groups.radicle.name;
        KillMode = "process";
        StateDirectory = [ "radicle" ];
        User = config.users.users.radicle.name;
        WorkingDirectory = env.HOME;
      }
      # The following options are only for optimizing:
      # systemd-analyze security ${serviceName}
      {
        AmbientCapabilities = "";

        BindReadOnlyPaths = [
          "-/etc/resolv.conf"
          "/run/systemd"
        ];

        CapabilityBoundingSet = "";
        DeviceAllow = ""; # ProtectClock= adds DeviceAllow=char-rtc r
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectoryMode = "700";
        SocketBindDeny = [ "any" ];
        StateDirectoryMode = "0750";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@aio"
          "~@chown"
          "~@keyring"
          "~@memlock"
          "~@privileged"
          "~@resources"
          "~@setuid"
          "~@timer"
        ];

        # This is for BindPaths= and BindReadOnlyPaths=
        # to allow traversal of directories they create inside RootDirectory=
        UMask = "0066";
      }
    ];

    wantedBy = [ "multi-user.target" ];
  };
in
{
  options = {
    services.radicle = {
      enable = lib.mkEnableOption "Radicle Seed Node";
      package = lib.mkPackageOption pkgs "radicle-node" { };

      checkConfig =
        lib.mkEnableOption "checking the {file}`config.json` file resulting from {option}`services.radicle.settings`"
        // {
          default = true;
        };

      configFile = lib.mkOption {
        default = (json.generate "config.json" cfg.settings).overrideAttrs (previousAttrs: {
          # None of the usual phases are run here because runCommandWith uses buildCommand,
          # so just append to buildCommand what would usually be a checkPhase.
          buildCommand =
            previousAttrs.buildCommand
            + lib.optionalString cfg.checkConfig ''
              ln -s $out config.json
              install -D -m 644 /dev/stdin keys/radicle.pub <<<"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBgFMhajUng+Rjj/sCFXI9PzG8BQjru2n7JgUVF1Kbv5 snakeoil"
              export RAD_HOME=$PWD
              ${lib.getExe' pkgs.buildPackages.radicle-node "rad"} config >/dev/null || {
                cat -n config.json
                echo "Invalid config.json according to rad."
                echo "Please double-check your services.radicle.settings (producing the config.json above),"
                echo "some settings may be missing or have the wrong type."
                exit 1
              } >&2
            '';

          preferLocalBuild = true;
        });

        internal = true;
        type = lib.types.package;
      };

      httpd = {
        enable = lib.mkEnableOption "Radicle HTTP gateway to radicle-node";
        package = lib.mkPackageOption pkgs "radicle-httpd" { };

        aliases = lib.mkOption {
          default = { };
          description = "Alias and RID pairs to shorten git clone commands for repositories.";

          example = lib.literalExpression ''
            {
              heartwood = "rad:z3gqcJUoA1n9HaHKufZs5FCSGazv5";
            }
          '';

          type = lib.types.attrsOf lib.types.str;
        };

        extraArgs = lib.mkOption {
          default = [ ];
          description = "Extra arguments for `radicle-httpd`";
          type = with lib.types; listOf str;
        };

        listenAddress = lib.mkOption {
          default = "127.0.0.1";
          description = "The IP address on which `radicle-httpd` listens.";
          type = lib.types.str;
        };

        listenPort = lib.mkOption {
          default = 8080;
          description = "The port on which `radicle-httpd` listens.";
          type = lib.types.port;
        };

        nginx = lib.mkOption {
          default = null;

          description = ''
            With this option, you can customize an nginx virtual host which already has sensible defaults for `radicle-httpd`.
            Set to `{}` if you do not need any customization to the virtual host.
            If enabled, then by default, the {option}`serverName` is
            `radicle-''${config.networking.hostName}.''${config.networking.domain}`,
            TLS is active, and certificates are acquired via ACME.
            If this is set to null (the default), no nginx virtual host will be configured.
          '';

          example = lib.literalExpression ''
            {
              serverAliases = [
                "seed.''${config.networking.domain}"
              ];
              enableACME = false;
              useACMEHost = config.networking.domain;
            }
          '';

          # Type of a single virtual host, or null.
          type = lib.types.nullOr (
            lib.types.submodule (
              lib.recursiveUpdate (import ../web-servers/nginx/vhost-options.nix { inherit config lib; }) {
                options.serverName = {
                  default = "radicle-${config.networking.hostName}.${config.networking.domain}";
                  defaultText = "radicle-\${config.networking.hostName}.\${config.networking.domain}";
                };
              }
            )
          );
        };
      };

      node = {
        extraArgs = lib.mkOption {
          default = [ ];
          description = "Extra arguments for `radicle-node`";
          type = with lib.types; listOf str;
        };

        listenAddress = lib.mkOption {
          default = "[::]";
          description = "The IP address on which `radicle-node` listens.";
          example = "127.0.0.1";
          type = lib.types.str;
        };

        listenPort = lib.mkOption {
          default = 8776;
          description = "The port on which `radicle-node` listens.";
          type = lib.types.port;
        };

        openFirewall = lib.mkEnableOption "opening the firewall for `radicle-node`";
      };

      privateKey = lib.mkOption {
        default = null;

        description = ''
          An SSH private key (as an absolute file path or Systemd credential name),
          usually generated by `rad auth`.

          If set to the default value of `null`, radicle will import the private key from a credential
          named `${credentials.privateKey}`.

          If configured as a credential name it will be imported via `ImportCredential=` in the service configuration.
          Refer to the systemd-creds documentation for more details <https://systemd.io/CREDENTIALS/>
        '';

        type = with lib.types; nullOr (either path str);
      };

      privateKeyPassphrase = lib.mkOption {
        default = null;

        description = ''
          A passphrase for an SSH private key (as a Systemd credential name),
          usually provided on generation of the key with `rad auth`.

          If set to the default value of `null`, radicle will optionally import the passphrase from a
          credential named `${credentials.privateKeyPassphrase}`.

          If the passphrase is not set, radicle will prompt for it.

          If configured as a credential name it will be imported via `ImportCredential=` in the service configuration.
          Refer to the systemd-creds documentation for more details <https://systemd.io/CREDENTIALS/>
        '';

        type = with lib.types; nullOr str;
      };

      publicKey = lib.mkOption {
        description = ''
          An SSH public key (as an absolute file path or directly as a string),
          usually generated by `rad auth`.

          Make sure to not include a comment if your key comes with a comment.
        '';

        type = with lib.types; either path str;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          See <https://radicle.network/nodes/iris.radicle.network/rad:z3gqcJUoA1n9HaHKufZs5FCSGazv5/tree/radicle/src/node/config.rs#L275>
        '';

        example = lib.literalExpression ''
          {
            web.pinned.repositories = [
              "rad:z3gqcJUoA1n9HaHKufZs5FCSGazv5" # heartwood
              "rad:z3trNYnLWS11cJWC6BbxDs5niGo82" # rips
            ];
          }
        '';

        type = lib.types.submodule {
          freeformType = json.type;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = [
          rad-system
        ];

        networking.firewall = lib.mkIf cfg.node.openFirewall {
          allowedTCPPorts = [ cfg.node.listenPort ];
        };

        systemd.services.radicle-node = lib.mkMerge [
          (commonServiceConfig "radicle-node")
          {
            confinement.packages = [
              cfg.package
            ];

            description = "Radicle Node";
            documentation = [ "man:radicle-node(1)" ];

            serviceConfig = {
              ExecStart = "${lib.getExe' cfg.package "radicle-node"} --force --listen ${cfg.node.listenAddress}:${toString cfg.node.listenPort} ${lib.escapeShellArgs cfg.node.extraArgs}";
              Restart = lib.mkDefault "on-failure";
              RestartSec = "30";
              SocketBindAllow = [ "tcp:${toString cfg.node.listenPort}" ];

              SystemCallFilter = lib.mkAfter [
                # Needed by git upload-pack which calls alarm() and setitimer() when providing a rad clone
                "@timer"
              ];
            };
          }
          # Give only access to the private key to radicle-node.
          {
            serviceConfig =
              if cfg.privateKey == null then
                {
                  ImportCredential = [ credentials.privateKey ];
                }
              else if lib.types.path.check cfg.privateKey then
                {
                  LoadCredential = [ "${credentials.privateKey}:${cfg.privateKey}" ];
                }
              else
                {
                  ImportCredential = [ "${cfg.privateKey}:${credentials.privateKey}" ];
                };
          }
          {
            serviceConfig =
              if cfg.privateKeyPassphrase == null then
                {
                  ImportCredential = [ credentials.privateKeyPassphrase ];
                }
              else
                {
                  ImportCredential = [ "${cfg.privateKeyPassphrase}:${credentials.privateKeyPassphrase}" ];
                };
          }
        ];

        users = {
          groups.radicle = {
          };

          users.radicle = {
            description = "Radicle";
            group = "radicle";
            home = env.HOME;
            isSystemUser = true;
          };
        };
      }

      (lib.mkIf cfg.httpd.enable (
        lib.mkMerge [
          {
            systemd.services.radicle-httpd = lib.mkMerge [
              (commonServiceConfig "radicle-httpd")
              {
                confinement.packages = [
                  cfg.httpd.package
                ];

                description = "Radicle HTTP gateway to radicle-node";
                documentation = [ "man:radicle-httpd(1)" ];

                serviceConfig = {
                  ExecStart = lib.escapeShellArgs (
                    [
                      (lib.getExe' cfg.httpd.package "radicle-httpd")
                      "--listen=${cfg.httpd.listenAddress}:${toString cfg.httpd.listenPort}"
                    ]
                    ++ lib.flatten (
                      lib.mapAttrsToList (alias: rid: [
                        "--alias"
                        alias
                        rid
                      ]) cfg.httpd.aliases
                    )
                    ++ cfg.httpd.extraArgs
                  );

                  Restart = lib.mkDefault "on-failure";
                  RestartSec = "10";
                  SocketBindAllow = [ "tcp:${toString cfg.httpd.listenPort}" ];

                  SystemCallFilter = lib.mkAfter [
                    # Needed by git upload-pack which calls alarm() and setitimer() when providing a git clone
                    "@timer"
                  ];
                };
              }
            ];
          }

          (lib.mkIf (cfg.httpd.nginx != null) {
            services.nginx.virtualHosts.${cfg.httpd.nginx.serverName} = lib.mkMerge [
              cfg.httpd.nginx
              {
                enableACME = lib.mkDefault true;
                forceSSL = lib.mkDefault true;

                locations."/" = {
                  proxyPass = "http://${cfg.httpd.listenAddress}:${toString cfg.httpd.listenPort}";
                  recommendedProxySettings = true;
                };
              }
            ];

            services.radicle.settings = {
              node.alias = lib.mkDefault cfg.httpd.nginx.serverName;

              node.externalAddresses = lib.mkDefault [
                "${cfg.httpd.nginx.serverName}:${toString cfg.node.listenPort}"
              ];
            };
          })
        ]
      ))
    ]
  );

  meta.teams = [ lib.teams.radicle ];
}
