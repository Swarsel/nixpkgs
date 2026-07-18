# Seahorse.

{
  config,
  lib,
  pkgs,
  ...
}:

{

  ###### interface

  options = {

    programs.seahorse = {

      enable = lib.mkEnableOption "Seahorse, a GNOME application for managing encryption keys and passwords in the GNOME Keyring";

    };

  };

  ###### implementation

  config = lib.mkIf config.programs.seahorse.enable {

    environment.systemPackages = [
      pkgs.seahorse
    ];

    programs.ssh.askPassword = lib.mkDefault "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

    services.dbus.packages = [
      pkgs.seahorse
    ];

  };

}
