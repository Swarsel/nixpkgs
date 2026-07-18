{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    getExe
    maintainers
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    types
    ;
  cfg = config.services.tailscaleAuth;
in
{
  options.services.tailscaleAuth = {
    enable = mkEnableOption "tailscale.nginx-auth, to authenticate users via tailscale";
    package = mkPackageOption pkgs "tailscale-nginx-auth" { };

    group = mkOption {
      default = "tailscale-nginx-auth";
      description = "Group which runs tailscale-nginx-auth";
      type = types.str;
    };

    socketPath = mkOption {
      default = "/run/tailscale-nginx-auth/tailscale-nginx-auth.sock";

      description = ''
        Path of the socket listening to authorization requests.
      '';

      type = types.path;
    };

    user = mkOption {
      default = "tailscale-nginx-auth";
      description = "User which runs tailscale-nginx-auth";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;

    systemd.services.tailscale-nginx-auth = {
      after = [ "tailscaled.service" ];
      description = "Tailscale NGINX Authentication service";
      requires = [ "tailscale-nginx-auth.socket" ];

      serviceConfig = {
        BindPaths = [ "/run/tailscale/tailscaled.sock" ];
        CapabilityBoundingSet = "";
        DeviceAllow = "";
        ExecStart = getExe cfg.package;
        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "on-failure";
        RestrictAddressFamilies = [ "AF_UNIX" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "tailscale-nginx-auth";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
          "~@cpu-emulation"
          "~@debug"
          "~@keyring"
          "~@memlock"
          "~@obsolete"
          "~@privileged"
          "~@setuid"
        ];

        User = cfg.user;
      };
    };

    systemd.sockets.tailscale-nginx-auth = {
      description = "Tailscale NGINX Authentication socket";
      listenStreams = [ cfg.socketPath ];
      partOf = [ "tailscale-nginx-auth.service" ];

      socketConfig = {
        SocketGroup = cfg.group;
        SocketMode = "0660";
        SocketUser = cfg.user;
      };

      wantedBy = [ "sockets.target" ];
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      inherit (cfg) group;
      isSystemUser = true;
    };
  };

  meta.maintainers = with maintainers; [
    dan-theriault
  ];
}
