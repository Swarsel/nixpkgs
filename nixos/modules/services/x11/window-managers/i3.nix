{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.windowManager.i3;
  updateSessionEnvironmentScript = ''
    systemctl --user import-environment PATH DISPLAY XAUTHORITY DESKTOP_SESSION XDG_CONFIG_DIRS XDG_DATA_DIRS XDG_RUNTIME_DIR XDG_SESSION_ID DBUS_SESSION_BUS_ADDRESS || true
    dbus-update-activation-environment --systemd --all || true
  '';
in

{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "xserver"
      "windowManager"
      "i3-gaps"
      "enable"
    ] "i3-gaps was merged into i3. Use services.xserver.windowManager.i3.enable instead.")
  ];

  options.services.xserver.windowManager.i3 = {
    enable = mkEnableOption "i3 window manager";
    package = mkPackageOption pkgs "i3" { };

    configFile = mkOption {
      default = null;

      description = ''
        Path to the i3 configuration file.
        If left at the default value, $HOME/.i3/config will be used.
      '';

      type = with types; nullOr path;
    };

    extraPackages = mkOption {
      default = with pkgs; [
        dmenu
        i3status
      ];

      defaultText = literalExpression ''
        with pkgs; [
          dmenu
          i3status
        ]
      '';

      description = ''
        Extra packages to be installed system wide.
      '';

      type = with types; listOf package;
    };

    extraSessionCommands = mkOption {
      default = "";

      description = ''
        Shell commands executed just before i3 is started.
      '';

      type = types.lines;
    };

    updateSessionEnvironment = mkOption {
      default = true;

      description = ''
        Whether to run dbus-update-activation-environment and systemctl import-environment before session start.
        Required for xdg portals to function properly.
      '';

      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    environment.etc."i3/config" = mkIf (cfg.configFile != null) {
      source = cfg.configFile;
    };

    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;
    programs.i3lock.enable = mkDefault true;

    services.xserver.windowManager.session = [
      {
        name = "i3";

        start = ''
          ${cfg.extraSessionCommands}

          ${lib.optionalString cfg.updateSessionEnvironment updateSessionEnvironmentScript}

          ${cfg.package}/bin/i3 ${optionalString (cfg.configFile != null) "-c /etc/i3/config"} &
          waitPID=$!
        '';
      }
    ];
  };
}
