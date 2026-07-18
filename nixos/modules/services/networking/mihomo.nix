# NOTE:
# cfg.configFile contains secrets such as proxy servers' credential!
# we dont want plaintext secrets in world-readable `/nix/store`.

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mihomo;

  AmbientCapabilities =
    lib.optional cfg.tunMode "CAP_NET_ADMIN"
    ++ lib.optionals cfg.processesInfo [
      "CAP_DAC_READ_SEARCH"
      "CAP_SYS_PTRACE"
    ];
  CapabilityBoundingSet = AmbientCapabilities;
in
{
  options.services.mihomo = {
    enable = lib.mkEnableOption "Mihomo, A rule-based proxy in Go";
    package = lib.mkPackageOption pkgs "mihomo" { };

    configFile = lib.mkOption {
      description = "Configuration file to use.";
      type = lib.types.path;
    };

    extraOpts = lib.mkOption {
      default = null;
      description = "Extra command line options to use.";
      type = lib.types.nullOr lib.types.str;
    };

    processesInfo = lib.mkEnableOption ''
      necessary capabilities for rules about process information such as `process-name`
    '';

    tunMode = lib.mkEnableOption ''
      necessary capabilities for Mihomo's systemd service for TUN mode to function properly.

      Keep in mind, that you still need to enable TUN mode manually in Mihomo's configuration
    '';

    webui = lib.mkOption {
      default = null;

      description = ''
        Local web interface to use.

        You can also use the following website:
        - metacubexd:
          - <https://d.metacubex.one>
          - <https://metacubex.github.io/metacubexd>
          - <https://metacubexd.pages.dev>
        - yacd:
          - <https://yacd.haishan.me>
        - clash-dashboard:
          - <https://clash.razord.top>
      '';

      example = lib.literalExpression "pkgs.metacubexd";
      type = lib.types.nullOr lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    ### systemd service
    systemd.services."mihomo" = {
      after = [ "network-online.target" ];
      description = "Mihomo daemon, A rule-based proxy in Go.";
      documentation = [ "https://wiki.metacubex.one/" ];
      requires = [ "network-online.target" ];

      serviceConfig = {
        ### Hardening
        inherit AmbientCapabilities CapabilityBoundingSet;
        DeviceAllow = "";
        DynamicUser = true;

        ExecStart = lib.concatStringsSep " " [
          (lib.getExe cfg.package)
          "-d /var/lib/private/mihomo"
          "-f \${CREDENTIALS_DIRECTORY}/config.yaml"
          (lib.optionalString (cfg.webui != null) "-ext-ui ${cfg.webui}")
          (lib.optionalString (cfg.extraOpts != null) cfg.extraOpts)
        ];

        LoadCredential = "config.yaml:${cfg.configFile}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
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
        RestrictAddressFamilies = "AF_INET AF_INET6";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "mihomo";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service bpf";
        UMask = "0077";
      }
      // lib.optionalAttrs cfg.tunMode {
        PrivateDevices = false;
        PrivateUsers = false;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ Guanran928 ];
}
