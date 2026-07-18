{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.virtualisation.incus.agent;
in
{
  options = {
    virtualisation.incus.agent.enable = lib.mkEnableOption "Incus agent";
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [ config.virtualisation.incus.package.agent_loader ];
    systemd.packages = [ config.virtualisation.incus.package.agent_loader ];

    systemd.services.incus-agent = {
      enable = true;

      path = [
        pkgs.kmod
        pkgs.util-linux

        # allow `incus exec` to find system binaries
        "/run/current-system/sw"
      ];

      # avoid killing nixos-rebuild switch when executed through incus exec
      restartIfChanged = false;
      stopIfChanged = false;
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    teams = [ lib.teams.lxc ];
  };
}
