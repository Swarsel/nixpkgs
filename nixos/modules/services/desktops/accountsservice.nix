# AccountsService daemon.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  ###### interface
  options = {

    services.accounts-daemon = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable AccountsService, a DBus service for accessing
          the list of user accounts and information attached to those accounts.
        '';

        type = lib.types.bool;
      };

    };

  };

  ###### implementation
  config = lib.mkIf config.services.accounts-daemon.enable {

    # Accounts daemon looks for dbus interfaces in $XDG_DATA_DIRS/accountsservice
    environment.pathsToLink = [ "/share/accountsservice" ];
    environment.systemPackages = [ pkgs.accountsservice ];
    services.dbus.packages = [ pkgs.accountsservice ];
    systemd.packages = [ pkgs.accountsservice ];

    systemd.services.accounts-daemon =
      lib.recursiveUpdate
        {

          # Accounts daemon looks for dbus interfaces in $XDG_DATA_DIRS/accountsservice
          environment.XDG_DATA_DIRS = "${config.system.path}/share";
          wantedBy = [ "graphical.target" ];

        }
        (
          lib.optionalAttrs (!config.users.mutableUsers) {
            environment.NIXOS_USERS_PURE = "true";
          }
        );
  };

  meta = {
    teams = [ lib.teams.freedesktop ];
  };

}
