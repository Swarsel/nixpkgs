{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.uptermd;
in
{
  options = {
    services.uptermd = {
      enable = mkEnableOption "uptermd";

      extraFlags = mkOption {
        default = [ ];

        description = ''
          Extra flags passed to the uptermd command.
        '';

        example = [ "--debug" ];
        type = types.listOf types.str;
      };

      hostKey = mkOption {
        default = null;

        description = ''
          Path to SSH host key. If not defined, an ed25519 keypair is generated automatically.
        '';

        example = "/run/keys/upterm_host_ed25519_key";
        type = types.nullOr types.path;
      };

      listenAddress = mkOption {
        default = "[::]";

        description = ''
          Address the server will listen on.
        '';

        example = "127.0.0.1";
        type = types.str;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Whether to open the firewall for the port in {option}`services.uptermd.port`.
        '';

        type = types.bool;
      };

      port = mkOption {
        default = 2222;

        description = ''
          Port the server will listen on.
        '';

        type = types.port;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.uptermd = {
      after = [ "network.target" ];
      description = "Upterm Daemon";
      path = [ pkgs.openssh ];

      preStart = mkIf (cfg.hostKey == null) ''
        if ! [ -f ssh_host_ed25519_key ]; then
          ssh-keygen \
            -t ed25519 \
            -f ssh_host_ed25519_key \
            -N ""
        fi
      '';

      serviceConfig = {
        # Hardening
        AmbientCapabilities = mkIf (cfg.port < 1024) [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = mkIf (cfg.port < 1024) [ "CAP_NET_BIND_SERVICE" ];
        DynamicUser = true;

        ExecStart = "${pkgs.upterm}/bin/uptermd --ssh-addr ${cfg.listenAddress}:${toString cfg.port} --private-key ${
          if cfg.hostKey == null then "ssh_host_ed25519_key" else cfg.hostKey
        } ${concatStringsSep " " cfg.extraFlags}";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateUsers = cfg.port >= 1024;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";

        # AF_UNIX is for ssh-keygen, which relies on nscd to resolve the uid to a user
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "uptermd";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        WorkingDirectory = "/var/lib/uptermd";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
