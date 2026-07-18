{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.crossmacro;
in
{
  options.services.crossmacro = {
    enable = lib.mkEnableOption "CrossMacro, a cross-platform mouse and keyboard macro application";
    package = lib.mkPackageOption pkgs "crossmacro" { };
    daemonPackage = lib.mkPackageOption pkgs "crossmacro-daemon" { };

    users = lib.mkOption {
      default = [ ];
      description = "List of users granted permission to use CrossMacro.";

      example = [
        "alice"
        "bob"
      ];

      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.users != [ ];
        message = "CrossMacro: You must specify at least one user. Set `services.crossmacro.users`.";
      }
    ];

    environment.etc."polkit-1/actions/io.github.alper_han.crossmacro.policy".source =
      "${cfg.daemonPackage}/share/polkit-1/actions/io.github.alper_han.crossmacro.policy";

    environment.etc."polkit-1/rules.d/50-crossmacro.rules".source =
      "${cfg.daemonPackage}/share/polkit-1/rules.d/50-crossmacro.rules";

    environment.systemPackages = [ cfg.package ];
    hardware.uinput.enable = true;

    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
      ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="CrossMacro Virtual Input Device", ENV{LIBINPUT_ATTR_POINTER_ACCEL}="0"
    '';

    systemd.services.crossmacro = {
      after = [
        "network.target"
        "dbus.service"
        "polkit.service"
      ];

      description = "CrossMacro Input Daemon Service";
      documentation = [ "https://github.com/alper-han/CrossMacro" ];
      path = [ pkgs.polkit ];

      serviceConfig = {
        AmbientCapabilities = [
          "CAP_SYS_ADMIN"
          "CAP_CHOWN"
          "CAP_DAC_READ_SEARCH"
        ];

        CapabilityBoundingSet = [
          "CAP_SYS_ADMIN"
          "CAP_SETUID"
          "CAP_SETGID"
          "CAP_CHOWN"
          "CAP_DAC_READ_SEARCH"
        ];

        ExecStart = lib.getExe cfg.daemonPackage;
        Group = "crossmacro";
        Restart = "always";
        RestartSec = 5;
        RuntimeDirectory = "crossmacro";
        RuntimeDirectoryMode = "0750";
        Type = "notify";
        User = "crossmacro";
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "dbus.service"
        "polkit.service"
      ];
    };

    users.groups.crossmacro = { };

    users.users =
      lib.listToAttrs (
        map (user: {
          name = user;

          value = {
            extraGroups = [ "crossmacro" ];
          };
        }) cfg.users
      )
      // {
        crossmacro = {
          description = "CrossMacro Input Daemon User";

          extraGroups = [
            "input"
            "uinput"
          ];

          group = "crossmacro";
          isSystemUser = true;
        };
      };
  };

  meta.maintainers = with lib.maintainers; [ alper-han ];
}
