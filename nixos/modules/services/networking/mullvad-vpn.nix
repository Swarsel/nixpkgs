{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mullvad-vpn;
in
with lib;
{
  options.services.mullvad-vpn = {
    enable = mkOption {
      default = false;

      description = ''
        This option enables Mullvad VPN daemon.
      '';

      type = types.bool;
    };

    package = mkPackageOption pkgs "mullvad" {
      example = "pkgs.mullvad-vpn";

      extraDescription = ''
        `pkgs.mullvad` only provides the CLI tool, `pkgs.mullvad-vpn` provides both the CLI and the GUI.
      '';
    };

    enableEarlyBootBlocking = mkOption {
      default = false;

      description = ''
        This option activates an additional oneshot systemd service to ensure that the mullvad daemon
        will start and block traffic before any network configuration will be applied.
        This matches what upstream Mullvad distributes for their supported distros, but is disabled by
        default in NixOS as it may conflict with non-Mullvad network configuration.
      '';

      type = types.bool;
    };

    enableExcludeWrapper = mkOption {
      default = true;

      description = ''
        This option activates the wrapper that allows the use of mullvad-exclude.
        Might have minor security impact, so consider disabling if you do not use the feature.
      '';

      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "tun" ];
    environment.systemPackages = [ cfg.package ];

    # See https://github.com/NixOS/nixpkgs/issues/176603
    security.wrappers.mullvad-exclude = mkIf cfg.enableExcludeWrapper {
      group = "root";
      owner = "root";
      setuid = true;
      source = "${cfg.package}/bin/mullvad-exclude";
    };

    systemd.services.mullvad-daemon = {
      after = [
        "network-online.target"
        "NetworkManager.service"
        "systemd-resolved.service"
      ]
      ++ lib.optional cfg.enableEarlyBootBlocking "mullvad-early-boot-blocking.service";

      description = "Mullvad VPN daemon";
      # See https://github.com/NixOS/nixpkgs/issues/262681
      path = lib.optional config.networking.resolvconf.enable config.networking.resolvconf.package;

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/mullvad-daemon -v --disable-stdout-timestamps";
        Restart = "always";
        RestartSec = 1;
      };

      startLimitBurst = 5;
      startLimitIntervalSec = 20;
      wantedBy = [ "multi-user.target" ];

      wants = [
        "network.target"
        "network-online.target"
      ];
    };

    # see https://github.com/mullvad/mullvadvpn-app/blob/2025.14/dist-assets/linux/mullvad-early-boot-blocking.service
    systemd.services.mullvad-early-boot-blocking = mkIf cfg.enableEarlyBootBlocking {
      before = [
        "basic.target"
        "mullvad-daemon.service"
      ];

      description = "Mullvad early boot network blocker";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/mullvad-daemon --initialize-early-boot-firewall";
        Type = "oneshot";
      };

      unitConfig = {
        DefaultDependencies = "no";
      };

      wantedBy = [ "mullvad-daemon.service" ];
    };
  };

  meta.maintainers = with maintainers; [
    arcuru
  ];
}
