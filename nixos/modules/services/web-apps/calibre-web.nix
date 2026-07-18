{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.calibre-web;
  dataDir = if lib.hasPrefix "/" cfg.dataDir then cfg.dataDir else "/var/lib/${cfg.dataDir}";

  inherit (lib)
    concatStringsSep
    mkEnableOption
    mkIf
    mkOption
    optional
    optionals
    optionalString
    types
    ;
in
{
  options = {
    services.calibre-web = {
      options = {
        calibreLibrary = mkOption {
          default = null;

          description = ''
            Path to Calibre library.
          '';

          type = types.nullOr types.path;
        };

        enableBookConversion = mkOption {
          default = false;

          description = ''
            Configure path to the Calibre's ebook-convert in the DB.
          '';

          type = types.bool;
        };

        enableBookUploading = mkOption {
          default = false;

          description = ''
            Allow books to be uploaded via Calibre-Web UI.
          '';

          type = types.bool;
        };

        enableKepubify = mkEnableOption "kepub conversion support";

        reverseProxyAuth = {
          enable = mkOption {
            default = false;

            description = ''
              Enable authorization using auth proxy.
            '';

            type = types.bool;
          };

          header = mkOption {
            default = "";

            description = ''
              Auth proxy header name.
            '';

            type = types.str;
          };
        };
      };

      enable = mkEnableOption "Calibre-Web";
      package = lib.mkPackageOption pkgs "calibre-web" { };
      calibrePackage = lib.mkPackageOption pkgs "calibre" { };

      dataDir = mkOption {
        default = "calibre-web";

        description = ''
          Where Calibre-Web stores its data.
          Either an absolute path, or the directory name below {file}`/var/lib`.
        '';

        type = types.str;
      };

      group = mkOption {
        default = "calibre-web";
        description = "Group account under which Calibre-Web runs.";
        type = types.str;
      };

      listen = {
        ip = mkOption {
          default = "::1";

          description = ''
            IP address that Calibre-Web should listen on.
          '';

          type = types.str;
        };

        port = mkOption {
          default = 8083;

          description = ''
            Listen port for Calibre-Web.
          '';

          type = types.port;
        };
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Open ports in the firewall for the server.
        '';

        type = types.bool;
      };

      user = mkOption {
        default = "calibre-web";
        description = "User account under which Calibre-Web runs.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listen.port ];
    };

    systemd.services.calibre-web =
      let
        appDb = "${dataDir}/app.db";
        gdriveDb = "${dataDir}/gdrive.db";
        calibreWebCmd = "${cfg.package}/bin/calibre-web -p ${appDb} -g ${gdriveDb}";

        settings = concatStringsSep ", " (
          [
            "config_port = ${toString cfg.listen.port}"
            "config_uploading = ${if cfg.options.enableBookUploading then "1" else "0"}"
            "config_allow_reverse_proxy_header_login = ${
              if cfg.options.reverseProxyAuth.enable then "1" else "0"
            }"
            "config_reverse_proxy_login_header_name = '${cfg.options.reverseProxyAuth.header}'"
          ]
          ++ optional (
            cfg.options.calibreLibrary != null
          ) "config_calibre_dir = '${cfg.options.calibreLibrary}'"
          ++ optionals cfg.options.enableBookConversion [
            "config_converterpath = '${cfg.calibrePackage}/bin/ebook-convert'"
            "config_binariesdir = '${cfg.calibrePackage}/bin/'"
          ]
          ++ optional cfg.options.enableKepubify "config_kepubifypath = '${pkgs.kepubify}/bin/kepubify'"
        );
      in
      {
        after = [ "network.target" ];
        description = "Web app for browsing, reading and downloading eBooks stored in a Calibre database";
        # fix book cover cache directory defaults to a path under /nix/store/
        environment.CACHE_DIR = "/var/cache/calibre-web";

        serviceConfig = {
          AmbientCapabilities = "";
          CacheDirectory = "calibre-web";
          CacheDirectoryMode = "0750";
          CapabilityBoundingSet = "";
          ExecStart = "${calibreWebCmd} -i ${cfg.listen.ip}";

          ExecStartPre = pkgs.writeShellScript "calibre-web-pre-start" (
            ''
              __RUN_MIGRATIONS_AND_EXIT=1 ${calibreWebCmd}

              ${pkgs.sqlite}/bin/sqlite3 ${appDb} "update settings set ${settings}"
            ''
            + optionalString (cfg.options.calibreLibrary != null) ''
              test -f "${cfg.options.calibreLibrary}/metadata.db" || { echo "Invalid Calibre library"; exit 1; }
            ''
          );

          Group = cfg.group;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateIPC = true;
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

          ReadWritePaths =
            lib.optional (lib.hasPrefix "/" cfg.dataDir) cfg.dataDir
            ++ lib.optional (cfg.options.calibreLibrary != null) cfg.options.calibreLibrary;

          RemoveIPC = true;
          Restart = "on-failure";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
            "AF_NETLINK"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "~@obsolete"
            "~@privileged"
            "~@raw-io"
            "~@resources"
            "~@mount"
            "~@debug"
            "~@cpu-emulation"
          ];

          Type = "simple";
          User = cfg.user;
        }
        // lib.optionalAttrs (!(lib.hasPrefix "/" cfg.dataDir)) {
          StateDirectory = cfg.dataDir;
        };

        wantedBy = [ "multi-user.target" ];
      };

    systemd.tmpfiles.settings = lib.optionalAttrs (lib.hasPrefix "/" cfg.dataDir) {
      "10-calibre-web".${dataDir}.d = {
        inherit (cfg) user group;
        mode = "0700";
      };
    };

    users.groups = mkIf (cfg.group == "calibre-web") {
      calibre-web = { };
    };

    users.users = mkIf (cfg.user == "calibre-web") {
      calibre-web = {
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = [ ];
}
