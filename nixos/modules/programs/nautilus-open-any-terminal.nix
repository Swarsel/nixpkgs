{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nautilus-open-any-terminal;
in
{
  options.programs.nautilus-open-any-terminal = {
    enable = lib.mkEnableOption "nautilus-open-any-terminal";

    terminal = lib.mkOption {
      default = null;

      description = ''
        The terminal emulator to add to context-entry of nautilus. Supported terminal
        emulators are listed in <https://github.com/Stunkymonkey/nautilus-open-any-terminal#supported-terminal-emulators>.
      '';

      type = with lib.types; nullOr str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.pathsToLink = [
      "/share/nautilus-python/extensions"
    ];

    environment.sessionVariables = lib.mkIf (!config.services.desktopManager.gnome.enable) {
      NAUTILUS_4_EXTENSION_DIR = "${pkgs.nautilus-python}/lib/nautilus/extensions-4";
    };

    environment.systemPackages = with pkgs; [
      nautilus-python
      nautilus-open-any-terminal
    ];

    programs.dconf = lib.optionalAttrs (cfg.terminal != null) {
      enable = true;

      profiles.user.databases = [
        {
          lockAll = true;
          settings."com/github/stunkymonkey/nautilus-open-any-terminal".terminal = cfg.terminal;
        }
      ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [
      stunkymonkey
      linsui
    ];
  };
}
