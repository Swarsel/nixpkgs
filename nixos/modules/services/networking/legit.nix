{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optionalAttrs
    optional
    types
    ;

  cfg = config.services.legit;

  yaml = pkgs.formats.yaml { };
  configFile = yaml.generate "legit.yaml" cfg.settings;

  defaultStateDir = "/var/lib/legit";
  defaultStaticDir = "${cfg.settings.repo.scanPath}/static";
  defaultTemplatesDir = "${cfg.settings.repo.scanPath}/templates";
in
{
  options.services.legit = {
    enable = mkEnableOption "legit git web frontend";
    package = mkPackageOption pkgs "legit-web" { };

    group = mkOption {
      default = "legit";
      description = "Group account under which legit runs.";
      type = types.str;
    };

    settings = mkOption {
      default = { };

      description = ''
        The primary legit configuration. See the
        [sample configuration](https://github.com/icyphox/legit/blob/master/config.yaml)
        for possible values.
      '';

      type = types.submodule {
        options.dirs = {
          static = mkOption {
            default = "${pkgs.legit-web}/lib/legit/static";
            defaultText = literalExpression ''"''${pkgs.legit-web}/lib/legit/static"'';
            description = "Directories where static files are located.";
            type = types.path;
          };

          templates = mkOption {
            default = "${pkgs.legit-web}/lib/legit/templates";
            defaultText = literalExpression ''"''${pkgs.legit-web}/lib/legit/templates"'';
            description = "Directories where template files are located.";
            type = types.path;
          };
        };

        options.meta = {
          description = mkOption {
            default = "git frontend";
            description = "Website description.";
            type = types.str;
          };

          title = mkOption {
            default = "legit";
            description = "Website title.";
            type = types.str;
          };
        };

        options.repo = {
          ignore = mkOption {
            default = [ ];
            description = "Repositories to ignore.";
            type = types.listOf types.str;
          };

          mainBranch = mkOption {
            default = [
              "main"
              "master"
            ];

            description = "Main branch to look for.";
            type = types.listOf types.str;
          };

          readme = mkOption {
            default = [ ];
            description = "Readme files to look for.";
            type = types.listOf types.str;
          };

          scanPath = mkOption {
            default = defaultStateDir;
            description = "Directory where legit will scan for repositories.";
            type = types.path;
          };
        };

        options.server = {
          host = mkOption {
            default = "127.0.0.1";
            description = "Host address.";
            type = types.str;
          };

          name = mkOption {
            default = "localhost";
            description = "Server name.";
            type = types.str;
          };

          port = mkOption {
            default = 5555;
            description = "Legit port.";
            type = types.port;
          };
        };
      };
    };

    user = mkOption {
      default = "legit";
      description = "User account under which legit runs.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.legit = {
      after = [ "network.target" ];
      description = "legit git frontend";
      restartTriggers = [ configFile ];

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        ExecStart = "${cfg.package}/bin/legit -config ${configFile}";
        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
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
        ReadWritePaths = cfg.settings.repo.scanPath;
        RemoveIPC = true;
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        StateDirectory =
          [ ]
          ++ optional (cfg.settings.repo.scanPath == defaultStateDir) "legit"
          ++ optional (cfg.settings.dirs.static == defaultStaticDir) "legit/static"
          ++ optional (cfg.settings.dirs.templates == defaultTemplatesDir) "legit/templates";

        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        Type = "simple";
        UMask = "0077";
        User = cfg.user;
        WorkingDirectory = cfg.settings.repo.scanPath;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = optionalAttrs (cfg.group == "legit") {
      "${cfg.group}" = { };
    };

    users.users = optionalAttrs (cfg.user == "legit") {
      "${cfg.user}" = {
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };
}
