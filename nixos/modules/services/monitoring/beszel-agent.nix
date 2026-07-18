{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.beszel.agent;
in
{
  options.services.beszel.agent = {
    enable = lib.mkEnableOption "beszel agent";
    package = lib.mkPackageOption pkgs "beszel" { };

    environment = lib.mkOption {
      default = { };

      description = ''
        Environment variables for configuring the beszel-agent service.
        This field will end up public in /nix/store, for secret values (such as `KEY`) use `environmentFile`.

        See <https://www.beszel.dev/guide/environment-variables#agent> for available options.
      '';

      type = lib.types.submodule {
        options = {
          SKIP_SYSTEMD = lib.mkOption {
            default = false;

            description = ''
              Whether to disable systemd service monitoring.
              Enabling this option will skip systemd tracking and its setup in NixOS.
            '';

            type = lib.types.bool;
          };
        };

        freeformType = lib.types.attrsOf lib.types.str;
      };
    };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        File path containing environment variables for configuring the beszel-agent service in the format of an EnvironmentFile. See {manpage}`systemd.exec(5)`.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    extraPath = lib.mkOption {
      default = [ ];

      description = ''
        Extra packages to add to beszel path (such as nvidia-smi or rocm-smi).
      '';

      type = lib.types.listOf lib.types.package;
    };

    openFirewall = (lib.mkEnableOption "") // {
      description = "Whether to open the firewall port (default 45876).";
    };

    smartmon = {
      enable = lib.mkOption {
        default = false;
        description = "Include services.beszel.agent.smartmon.package in the Beszel agent path for disk monitoring and add the agent to the disk group.";
        example = true;
        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "smartmontools" { };

      deviceAllow = lib.mkOption {
        default = [ ];

        description = ''
          List of device paths to allow access to for SMART monitoring.
          This is only needed if the ambient capabilities are not sufficient.
          Devices will be granted read-only access.
        '';

        example = [
          "/dev/sda"
          "/dev/sdb"
          "/dev/nvme0"
        ];

        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      (
        if (builtins.hasAttr "PORT" cfg.environment) then
          (lib.strings.toInt cfg.environment.PORT)
        else
          45876
      )
    ];

    # Add D-Bus policy for systemd service monitoring following https://beszel.dev/guide/systemd#services-not-appearing
    services.dbus.packages = lib.optionals (!cfg.environment.SKIP_SYSTEMD) [
      (pkgs.writeTextDir "share/dbus-1/system.d/beszel-agent.conf" ''
        <?xml version="1.0" encoding="UTF-8"?> <!-- -*- XML -*- -->

        <!DOCTYPE busconfig PUBLIC
                  "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
                  "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">

        <busconfig>
          <policy user="beszel-agent">
            <allow
              send_destination="org.freedesktop.systemd1"
              send_type="method_call"
              send_path="/org/freedesktop/systemd1"
              send_interface="org.freedesktop.systemd1.Manager"
              send_member="ListUnits"
            />
          </policy>
        </busconfig>
      '')
    ];

    services.udev.extraRules = lib.optionalString cfg.smartmon.enable ''
      # Change NVMe devices to disk group ownership for S.M.A.R.T. monitoring
      KERNEL=="nvme[0-9]*", GROUP="disk", MODE="0660"
    '';

    systemd.services.beszel-agent = {
      after = [ "network-online.target" ];
      description = "Beszel Server Monitoring Agent";

      environment = lib.mapAttrs (
        _: value: if lib.isBool value then (lib.boolToString value) else value
      ) cfg.environment;

      path =
        cfg.extraPath
        ++ lib.optionals cfg.smartmon.enable [ cfg.smartmon.package ]
        ++ lib.optionals (builtins.elem "nvidia" config.services.xserver.videoDrivers) [
          (lib.getBin config.hardware.nvidia.package)
        ]
        ++ lib.optionals (builtins.elem "amdgpu" config.services.xserver.videoDrivers) [
          (lib.getBin pkgs.rocmPackages.rocm-smi)
        ]
        ++ lib.optionals (builtins.elem "intel" config.services.xserver.videoDrivers) [
          (lib.getBin pkgs.intel-gpu-tools)
        ];

      serviceConfig = {
        # Capabilities needed for SMART monitoring
        AmbientCapabilities = lib.mkIf cfg.smartmon.enable [
          "CAP_SYS_RAWIO"
          "CAP_SYS_ADMIN"
        ];

        CapabilityBoundingSet = lib.mkIf cfg.smartmon.enable [
          "CAP_SYS_RAWIO"
          "CAP_SYS_ADMIN"
        ];

        # Device access for SMART monitoring
        DeviceAllow = lib.mkIf (cfg.smartmon.enable && cfg.smartmon.deviceAllow != [ ]) (
          map (device: "${device} r") cfg.smartmon.deviceAllow
        );

        DynamicUser = true;
        EnvironmentFile = cfg.environmentFile;

        ExecStart = ''
          ${cfg.package}/bin/beszel-agent
        '';

        LockPersonality = true;
        NoNewPrivileges = !cfg.smartmon.enable;
        PrivateDevices = !cfg.smartmon.enable;
        PrivateTmp = true;
        PrivateUsers = !cfg.smartmon.enable && !cfg.environment.SKIP_SYSTEMD;
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = "read-only";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = "30s";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        # adds ability to monitor docker/podman containers
        SupplementaryGroups =
          lib.optionals config.virtualisation.docker.enable [ "docker" ]
          ++ lib.optionals (
            config.virtualisation.podman.enable && config.virtualisation.podman.dockerSocket.enable
          ) [ "podman" ]
          ++ lib.optionals cfg.smartmon.enable [ "disk" ];

        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [ "@system-service" ];
        Type = "simple";
        UMask = 27;
        User = "beszel-agent";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups.beszel-agent = lib.mkIf (!cfg.environment.SKIP_SYSTEMD) { };

    users.users.beszel-agent = lib.mkIf (!cfg.environment.SKIP_SYSTEMD) {
      group = "beszel-agent";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [
    BonusPlay
    arunoruto
  ];
}
