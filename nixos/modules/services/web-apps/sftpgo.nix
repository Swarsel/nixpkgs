{
  config,
  lib,
  pkgs,
  options,
  utils,
  ...
}:

with lib;

let
  cfg = config.services.sftpgo;
  defaultUser = "sftpgo";
  settingsFormat = pkgs.formats.json { };
  configFile = settingsFormat.generate "sftpgo.json" cfg.settings;
  hasPrivilegedPorts = any (port: port > 0 && port < 1024) (
    catAttrs "port" (
      cfg.settings.httpd.bindings
      ++ cfg.settings.ftpd.bindings
      ++ cfg.settings.sftpd.bindings
      ++ cfg.settings.webdavd.bindings
    )
  );
in
{
  options.services.sftpgo = {
    enable = mkOption {
      default = false;
      description = "sftpgo";
      type = types.bool;
    };

    package = mkPackageOption pkgs "sftpgo" { };

    dataDir = mkOption {
      default = "/var/lib/sftpgo";

      description = ''
        The directory where SFTPGo stores its data files.
      '';

      type = types.path;
    };

    extraArgs = mkOption {
      default = [ ];

      description = ''
        Additional command line arguments to pass to the sftpgo daemon.
      '';

      example = [
        "--log-level"
        "info"
      ];

      type = with types; listOf str;
    };

    extraReadWriteDirs = mkOption {
      default = [ ];

      description = ''
        Extra directories where SFTPGo is allowed to write to.
      '';

      type = types.listOf types.path;
    };

    group = mkOption {
      default = defaultUser;

      description = ''
        Group name under which SFTPGo runs.
      '';

      type = types.str;
    };

    loadDataFile = mkOption {
      default = null;

      description = ''
        Path to a json file containing users and folders to load (or update) on startup.
        Check the [documentation](https://sftpgo.github.io/latest/config-file/)
        for the `--loaddata-from` command line argument for more info.
      '';

      type = with types; nullOr path;
    };

    settings = mkOption {
      default = { };

      description = ''
        The primary sftpgo configuration. See the
        [configuration reference](https://sftpgo.github.io/latest/config-file/)
        for possible values.
      '';

      type =
        with types;
        submodule {
          options = {
            ftpd.bindings = mkOption {
              default = [ ];

              description = ''
                Configure listen addresses and ports for ftpd.
              '';

              type = types.listOf (
                types.submodule {
                  options = {
                    address = mkOption {
                      default = "127.0.0.1";

                      description = ''
                        Network listen address. Leave blank to listen on all available network interfaces.
                        On *NIX you can specify an absolute path to listen on a Unix-domain socket.
                      '';

                      type = types.str;
                    };

                    port = mkOption {
                      default = 0;

                      description = ''
                        The port for serving FTP requests.

                        Setting the port to `0` disables listening on this interface binding.
                      '';

                      type = types.port;
                    };
                  };

                  freeformType = settingsFormat.type;
                }
              );
            };

            httpd.bindings = mkOption {
              default = [ ];

              description = ''
                Configure listen addresses and ports for httpd.
              '';

              type = types.listOf (
                types.submodule {
                  options = {
                    address = mkOption {
                      default = "127.0.0.1";

                      description = ''
                        Network listen address. Leave blank to listen on all available network interfaces.
                        On *NIX you can specify an absolute path to listen on a Unix-domain socket.
                      '';

                      type = types.str;
                    };

                    enable_web_admin = mkOption {
                      default = true;

                      description = ''
                        Enable the built-in web admin for this interface binding.
                      '';

                      type = types.bool;
                    };

                    enable_web_client = mkOption {
                      default = true;

                      description = ''
                        Enable the built-in web client for this interface binding.
                      '';

                      type = types.bool;
                    };

                    port = mkOption {
                      default = 8080;

                      description = ''
                        The port for serving HTTP(S) requests.

                        Setting the port to `0` disables listening on this interface binding.
                      '';

                      type = types.port;
                    };
                  };

                  freeformType = settingsFormat.type;
                }
              );
            };

            sftpd.bindings = mkOption {
              default = [ ];

              description = ''
                Configure listen addresses and ports for sftpd.
              '';

              type = types.listOf (
                types.submodule {
                  options = {
                    address = mkOption {
                      default = "127.0.0.1";

                      description = ''
                        Network listen address. Leave blank to listen on all available network interfaces.
                        On *NIX you can specify an absolute path to listen on a Unix-domain socket.
                      '';

                      type = types.str;
                    };

                    port = mkOption {
                      default = 0;

                      description = ''
                        The port for serving SFTP requests.

                        Setting the port to `0` disables listening on this interface binding.
                      '';

                      type = types.port;
                    };
                  };

                  freeformType = settingsFormat.type;
                }
              );
            };

            smtp = mkOption {
              default = { };

              description = ''
                SMTP configuration section.
              '';

              type = types.submodule {
                options = {
                  auth_type = mkOption {
                    default = 0;

                    description = ''
                      - `0`: Plain
                      - `1`: Login
                      - `2`: CRAM-MD5
                    '';

                    type = types.enum [
                      0
                      1
                      2
                    ];
                  };

                  encryption = mkOption {
                    default = 1;

                    description = ''
                      Encryption scheme:
                      - `0`: No encryption
                      - `1`: TLS
                      - `2`: STARTTLS
                    '';

                    type = types.enum [
                      0
                      1
                      2
                    ];
                  };

                  from = mkOption {
                    default = "SFTPGo <sftpgo@example.com>";

                    description = ''
                      From address.
                    '';

                    type = types.str;
                  };

                  host = mkOption {
                    default = "";

                    description = ''
                      Location of SMTP email server. Leave empty to disable email sending capabilities.
                    '';

                    type = types.str;
                  };

                  port = mkOption {
                    default = 465;
                    description = "Port of the SMTP Server.";
                    type = types.port;
                  };

                  user = mkOption {
                    default = "sftpgo";
                    description = "SMTP username.";
                    type = types.str;
                  };
                };

                freeformType = settingsFormat.type;
              };
            };

            webdavd.bindings = mkOption {
              default = [ ];

              description = ''
                Configure listen addresses and ports for webdavd.
              '';

              type = types.listOf (
                types.submodule {
                  options = {
                    address = mkOption {
                      default = "127.0.0.1";

                      description = ''
                        Network listen address. Leave blank to listen on all available network interfaces.
                        On *NIX you can specify an absolute path to listen on a Unix-domain socket.
                      '';

                      type = types.str;
                    };

                    port = mkOption {
                      default = 0;

                      description = ''
                        The port for serving WebDAV requests.

                        Setting the port to `0` disables listening on this interface binding.
                      '';

                      type = types.port;
                    };
                  };

                  freeformType = settingsFormat.type;
                }
              );
            };
          };

          freeformType = settingsFormat.type;
        };
    };

    user = mkOption {
      default = defaultUser;

      description = ''
        User account name under which SFTPGo runs.
      '';

      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services.sftpgo.settings = (
      mapAttrs (name: mkDefault) {
        ftpd.bindings = [ { port = 0; } ];
        httpd.bindings = [ { port = 0; } ];
        httpd.openapi_path = "${cfg.package}/share/sftpgo/openapi";
        httpd.static_files_path = "${cfg.package}/share/sftpgo/static";
        httpd.templates_path = "${cfg.package}/share/sftpgo/templates";
        sftpd.bindings = [ { port = 0; } ];
        smtp.templates_path = "${cfg.package}/share/sftpgo/templates";
        webdavd.bindings = [ { port = 0; } ];
      }
    );

    systemd.services.sftpgo = {
      after = [ "network.target" ];
      description = "SFTPGo daemon";

      environment = {
        SFTPGO_CONFIG_FILE = mkDefault configFile;
        SFTPGO_LOADDATA_FROM = mkIf (cfg.loadDataFile != null) cfg.loadDataFile;
        SFTPGO_LOG_FILE_PATH = mkDefault ""; # log to journal
      };

      serviceConfig = mkMerge [
        {
          # Service hardening
          CapabilityBoundingSet = [ (optionalString hasPrivilegedPorts "CAP_NET_BIND_SERVICE") ];
          DevicePolicy = "closed";
          ExecReload = "${pkgs.util-linux}/bin/kill -s HUP $MAINPID";
          ExecStart = "${cfg.package}/bin/sftpgo serve ${utils.escapeSystemdExecArgs cfg.extraArgs}";
          Group = cfg.group;
          KillMode = "mixed";
          LimitNOFILE = 8192; # taken from upstream
          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
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
          ReadWritePaths = [ cfg.dataDir ] ++ cfg.extraReadWriteDirs;
          RemoveIPC = true;
          RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];

          Type = "simple";
          UMask = "0077";
          User = cfg.user;
          WorkingDirectory = cfg.dataDir;
        }
        (mkIf hasPrivilegedPorts {
          AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        })
        (mkIf (cfg.dataDir == options.services.sftpgo.dataDir.default) {
          StateDirectory = baseNameOf cfg.dataDir;
        })
      ];

      wantedBy = [ "multi-user.target" ];
    };

    users = optionalAttrs (cfg.user == defaultUser) {
      groups = {
        ${defaultUser} = {
          members = [ defaultUser ];
        };
      };

      users = {
        ${defaultUser} = {
          description = "SFTPGo system user";
          group = defaultUser;
          home = cfg.dataDir;
          isSystemUser = true;
        };
      };
    };
  };
}
