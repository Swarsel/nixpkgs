{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.onedrive;

  onedriveLauncher = pkgs.writeShellScriptBin "onedrive-launcher" ''
    # XDG_CONFIG_HOME is not recognized in the environment here.
    if [ -f $HOME/.config/onedrive-launcher ]
    then
      # Hopefully using underscore boundary helps locate variables
      for _onedrive_config_dirname_ in $(cat $HOME/.config/onedrive-launcher | grep -v '[ \t]*#' )
      do
        systemctl --user start onedrive@$_onedrive_config_dirname_
      done
    else
      systemctl --user start onedrive@onedrive
    fi
  '';

in
{
  options.services.onedrive = {
    enable = lib.mkEnableOption "OneDrive service";
    package = lib.mkPackageOption pkgs "onedrive" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.user.services.onedrive-launcher = {
      serviceConfig = {
        ExecStart = "${onedriveLauncher}/bin/onedrive-launcher";
        Type = "oneshot";
      };

      wantedBy = [ "default.target" ];
    };

    systemd.user.services."onedrive@" = {
      description = "Onedrive sync service";

      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/onedrive --monitor --confdir=%h/.config/%i
        '';

        Restart = "on-failure";
        RestartPreventExitStatus = 3;
        RestartSec = 3;
        Type = "simple";
      };
    };
  };

  meta.doc = ./onedrive.md;
}
