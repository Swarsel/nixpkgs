{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.haproxy;
  haproxyCfg = pkgs.writeText "haproxy.conf" ''
    global
      # needed for hot-reload to work without dropping packets in multi-worker mode
      stats socket /run/haproxy/haproxy.sock mode 600 expose-fd listeners level user
    ${cfg.config}
  '';
in
{
  options = {
    services.haproxy = {

      config = lib.mkOption {
        default = null;

        description = ''
          Contents of the HAProxy configuration file,
          {file}`haproxy.conf`.
        '';

        type = lib.types.nullOr lib.types.lines;
      };

      enable = lib.mkEnableOption "HAProxy, the reliable, high performance TCP/HTTP load balancer";
      package = lib.mkPackageOption pkgs "haproxy" { };

      group = lib.mkOption {
        default = "haproxy";
        description = "Group account under which haproxy runs.";
        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "haproxy";
        description = "User account under which haproxy runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.config != null;
        message = "You must provide services.haproxy.config.";
      }
    ];

    # configuration file indirection is needed to support reloading
    environment.etc."haproxy.cfg".source = haproxyCfg;

    systemd.services.haproxy = {
      after = [ "network.target" ];
      description = "HAProxy";

      serviceConfig = {
        # needed in case we bind to port < 1024
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";

        # support reloading
        ExecReload = [
          "${pkgs.coreutils}/bin/ln -sf ${lib.getExe cfg.package} /run/haproxy/haproxy"
          "${pkgs.coreutils}/bin/kill -USR2 $MAINPID"
        ];

        ExecStart = "/run/haproxy/haproxy -Ws -f /etc/haproxy.cfg -p /run/haproxy/haproxy.pid";

        ExecStartPre = [
          # when the master process receives USR2, it reloads itself using exec(argv[0]),
          # so we create a symlink there and update it before reloading
          "${pkgs.coreutils}/bin/ln -sf ${lib.getExe cfg.package} /run/haproxy/haproxy"
        ];

        Group = cfg.group;
        KillMode = "mixed";
        # upstream hardening options
        NoNewPrivileges = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "always";
        RuntimeDirectory = "haproxy";
        SuccessExitStatus = "143";
        SystemCallFilter = "~@cpu-emulation @keyring @module @obsolete @raw-io @reboot @swap @sync";
        Type = "notify";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.group == "haproxy") {
      haproxy = { };
    };

    users.users = lib.optionalAttrs (cfg.user == "haproxy") {
      haproxy = {
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };
}
