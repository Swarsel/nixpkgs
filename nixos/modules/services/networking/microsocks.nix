{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.microsocks;

  cmd =
    if cfg.execWrapper != null then
      "${cfg.execWrapper} ${cfg.package}/bin/microsocks"
    else
      "${cfg.package}/bin/microsocks";
  args = [
    "-i"
    cfg.ip
    "-p"
    (toString cfg.port)
  ]
  ++ lib.optionals (cfg.authOnce) [ "-1" ]
  ++ lib.optionals (cfg.disableLogging) [ "-q" ]
  ++ lib.optionals (cfg.outgoingBindIp != null) [
    "-b"
    cfg.outgoingBindIp
  ]
  ++ lib.optionals (cfg.authUsername != null) [
    "-u"
    cfg.authUsername
  ];
in
{
  options.services.microsocks = {
    enable = lib.mkEnableOption "Tiny, portable SOCKS5 server with very moderate resource usage";
    package = lib.mkPackageOption pkgs "microsocks" { };

    authOnce = lib.mkOption {
      default = false;

      description = ''
        If true, once a specific ip address authed successfully with user/pass,
        it is added to a whitelist and may use the proxy without auth.
      '';

      type = lib.types.bool;
    };

    authPasswordFile = lib.mkOption {
      default = null;
      description = "Path to a file containing the password for authentication.";
      example = "/run/secrets/microsocks-password";
      type = lib.types.nullOr lib.types.path;
    };

    authUsername = lib.mkOption {
      default = null;
      description = "Optional username to use for authentication.";
      example = "alice";
      type = lib.types.nullOr lib.types.str;
    };

    disableLogging = lib.mkOption {
      default = false;
      description = "If true, microsocks will not log any messages to stdout/stderr.";
      type = lib.types.bool;
    };

    execWrapper = lib.mkOption {
      default = null;

      description = ''
        An optional command to prepend to the microsocks command (such as proxychains, or a VPN exclude command).
      '';

      example = ''
        ''${pkgs.mullvad-vpn}/bin/mullvad-exclude
      '';

      type = lib.types.nullOr lib.types.str;
    };

    group = lib.mkOption {
      default = "microsocks";
      description = "Group microsocks runs as.";
      type = lib.types.str;
    };

    ip = lib.mkOption {
      default = "127.0.0.1";

      description = ''
        IP on which microsocks should listen. Defaults to 127.0.0.1 for
        security reasons.
      '';

      type = lib.types.str;
    };

    outgoingBindIp = lib.mkOption {
      default = null;
      description = "Specifies which ip outgoing connections are bound to";
      type = lib.types.nullOr lib.types.str;
    };

    port = lib.mkOption {
      default = 1080;
      description = "Port on which microsocks should listen.";
      type = lib.types.port;
    };

    user = lib.mkOption {
      default = "microsocks";
      description = "User microsocks runs as.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.authUsername != null) == (cfg.authPasswordFile != null);
        message = "Need to set both authUsername and authPasswordFile for microsocks";
      }
    ];

    systemd.services.microsocks = {
      enable = true;
      after = [ "network.target" ];
      description = "a tiny socks server";

      script =
        if cfg.authPasswordFile != null then
          ''
            PASSWORD=$(cat "$CREDENTIALS_DIRECTORY/MICROSOCKS_PASSWORD_FILE")
            ${cmd} ${lib.escapeShellArgs args} -P "$PASSWORD"
          ''
        else
          ''
            ${cmd} ${lib.escapeShellArgs args}
          '';

      serviceConfig = {
        Group = cfg.group;

        LoadCredential = lib.optionalString (
          cfg.authPasswordFile != null
        ) "MICROSOCKS_PASSWORD_FILE:${cfg.authPasswordFile}";

        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = 10;

        RestrictNamespaces = [
          "cgroup"
          "ipc"
          "pid"
          "user"
          "uts"
        ];

        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups = lib.mkIf (cfg.group == "microsocks") {
        microsocks = { };
      };

      users = lib.mkIf (cfg.user == "microsocks") {
        microsocks = {
          group = cfg.group;
          isSystemUser = true;
        };
      };
    };
  };
}
