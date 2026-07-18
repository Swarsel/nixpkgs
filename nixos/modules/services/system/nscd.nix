{
  config,
  lib,
  pkgs,
  ...
}:
let

  nssModulesPath = config.system.nssModules.path;
  cfg = config.services.nscd;

in

{

  ###### interface

  options = {

    services.nscd = {

      config = lib.mkOption {
        default = builtins.readFile ./nscd.conf;

        description = ''
          Configuration to use for Name Service Cache Daemon.
          Only used in case glibc-nscd is used.
        '';

        type = lib.types.lines;
      };

      enable = lib.mkOption {
        default = true;

        description = ''
          Whether to enable the Name Service Cache Daemon.
          Disabling this is strongly discouraged, as this effectively disables NSS Lookups
          from all non-glibc NSS modules, including the ones provided by systemd.
        '';

        type = lib.types.bool;
      };

      package = lib.mkOption {
        default =
          if pkgs.stdenv.hostPlatform.libc == "glibc" then pkgs.stdenv.cc.libc.bin else pkgs.glibc.bin;

        defaultText = lib.literalExpression ''
          if pkgs.stdenv.hostPlatform.libc == "glibc"
            then pkgs.stdenv.cc.libc.bin
            else pkgs.glibc.bin;
        '';

        description = ''
          package containing the nscd binary to be used by the service.
          Ignored when enableNsncd is set to true.
        '';

        type = lib.types.package;
      };

      enableNsncd = lib.mkOption {
        default = true;

        description = ''
          Whether to use nsncd instead of nscd from glibc.
          This is a nscd-compatible daemon, that proxies lookups, without any caching.
          Using nscd from glibc is discouraged.
        '';

        type = lib.types.bool;
      };

      group = lib.mkOption {
        default = "nscd";

        description = ''
          User group under which nscd runs.
        '';

        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "nscd";

        description = ''
          User account under which nscd runs.
        '';

        type = lib.types.str;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    environment.etc."nscd.conf".text = cfg.config;

    systemd.services.nscd = {
      before = [
        "nss-lookup.target"
        "nss-user-lookup.target"
      ];

      description = "Name Service Cache Daemon" + lib.optionalString cfg.enableNsncd " (nsncd)";

      environment = {
        LD_LIBRARY_PATH = nssModulesPath;
      };

      requiredBy = [
        "nss-lookup.target"
        "nss-user-lookup.target"
      ];

      restartTriggers = lib.optionals (!cfg.enableNsncd) (
        [
          config.environment.etc.hosts.source
          config.environment.etc."nsswitch.conf".source
          config.environment.etc."nscd.conf".source
        ]
        ++ lib.optionals config.users.mysql.enable [
          config.environment.etc."libnss-mysql.cfg".source
          config.environment.etc."libnss-mysql-root.cfg".source
        ]
      );

      # In some configurations, nscd needs to be started as root; it will
      # drop privileges after all the NSS modules have read their
      # configuration files. So prefix the ExecStart command with "!" to
      # prevent systemd from dropping privileges early. See ExecStart in
      # systemd.service(5). We use a static user, because some NSS modules
      # sill want to read their configuration files after the privilege drop
      # and so users can set the owner of those files to the nscd user.
      serviceConfig = {
        # https://github.com/twosigma/nsncd/pull/33/files#r1496927653
        Environment = [ "NSNCD_HANDOFF_TIMEOUT=10" ];

        ExecReload = lib.optionals (!cfg.enableNsncd) [
          "${cfg.package}/bin/nscd --invalidate passwd"
          "${cfg.package}/bin/nscd --invalidate group"
          "${cfg.package}/bin/nscd --invalidate hosts"
        ];

        ExecStart = if cfg.enableNsncd then "${pkgs.nsncd}/bin/nsncd" else "!@${cfg.package}/bin/nscd nscd";
        Group = cfg.group;
        NoNewPrivileges = true;
        PIDFile = "/run/nscd/nscd.pid";
        PrivateTmp = true;
        ProtectHome = "read-only";
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "always";
        RestrictSUIDSGID = true;
        RuntimeDirectory = "nscd";
        Type = if cfg.enableNsncd then "notify" else "forking";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "nss-lookup.target"
        "nss-user-lookup.target"
      ];
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      group = cfg.group;
      isSystemUser = true;
    };
  };
}
