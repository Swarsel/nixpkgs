{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.sillytavern;
  defaultUser = "sillytavern";
  defaultGroup = "sillytavern";
in
{
  options = {
    services.sillytavern = {
      enable = lib.mkEnableOption "sillytavern";
      package = lib.mkPackageOption pkgs "sillytavern" { };

      configFile = lib.mkOption {
        default = "${cfg.package}/lib/node_modules/sillytavern/config.yaml";
        defaultText = lib.literalExpression "\${cfg.package}/lib/node_modules/sillytavern/config.yaml";

        description = ''
          Path to the SillyTavern configuration file.
        '';

        type = lib.types.path;
      };

      group = lib.mkOption {
        default = defaultGroup;

        description = ''
          Group account under which the web-application run.
        '';

        type = lib.types.str;
      };

      listen = lib.mkOption {
        default = null;

        description = ''
          Whether to listen on all network interfaces.
        '';

        example = true;
        type = lib.types.nullOr lib.types.bool;
      };

      listenAddressIPv4 = lib.mkOption {
        default = null;

        description = ''
          Specific IPv4 address to listen to.
        '';

        example = "127.0.0.1";
        type = lib.types.nullOr lib.types.str;
      };

      listenAddressIPv6 = lib.mkOption {
        default = null;

        description = ''
          Specific IPv6 address to listen to.
        '';

        example = "::1";
        type = lib.types.nullOr lib.types.str;
      };

      port = lib.mkOption {
        default = null;

        description = ''
          Port on which SillyTavern will listen.
        '';

        example = 8045;
        type = lib.types.nullOr lib.types.port;
      };

      user = lib.mkOption {
        default = defaultUser;

        description = ''
          User account under which the web-application run.
        '';

        type = lib.types.str;
      };

      whitelist = lib.mkOption {
        default = null;

        description = ''
          Enables whitelist mode.
        '';

        example = true;
        type = lib.types.nullOr lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.sillytavern = {
      after = [ "network.target" ];
      description = "Silly Tavern";
      environment.XDG_DATA_HOME = "%S";
      # required by sillytavern's extension manager
      path = [ pkgs.gitMinimal ];

      serviceConfig = {
        BindPaths = [
          "%S/SillyTavern/extensions:${cfg.package}/lib/node_modules/sillytavern/public/scripts/extensions/third-party"
        ];

        # Security hardening
        CapabilityBoundingSet = [ "" ];

        ExecStart =
          let
            f = x: name: lib.optional (x != null) "--${name}=${toString x}";
          in
          lib.concatStringsSep " " (
            [
              "${lib.getExe cfg.package}"
            ]
            ++ f cfg.port "port"
            ++ f cfg.listen "listen"
            ++ f cfg.listenAddressIPv4 "listenAddressIPv4"
            ++ f cfg.listenAddressIPv6 "listenAddressIPv6"
            ++ f cfg.whitelist "whitelist"
          );

        Group = cfg.group;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        Restart = "always";
        StateDirectory = "SillyTavern";
        Type = "simple";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings.sillytavern = {
      "/var/lib/SillyTavern/config.yaml"."L+" = {
        inherit (cfg) user group;
        argument = cfg.configFile;
        mode = "0600";
      };

      "/var/lib/SillyTavern/data".d = {
        inherit (cfg) user group;
        mode = "0700";
      };

      "/var/lib/SillyTavern/extensions".d = {
        inherit (cfg) user group;
        mode = "0700";
      };
    };

    users.groups.${cfg.group} = lib.mkIf (cfg.group == defaultGroup) { };

    users.users.${cfg.user} = lib.mkIf (cfg.user == defaultUser) {
      inherit (cfg) group;
      description = "sillytavern service user";
      isSystemUser = true;
    };
  };

  meta.maintainers = [
    lib.maintainers.wrvsrx
    lib.maintainers.A1ca7raz
  ];
}
