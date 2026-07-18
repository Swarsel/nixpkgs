{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.soundmodem;
in
{
  options = {
    programs.soundmodem = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to add Soundmodem to the global environment and configure a
          wrapper for 'soundmodemconfig' for users in the 'soundmodem' group.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "soundmodem" { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    security.wrappers.soundmodemconfig = {
      group = "soundmodem";
      owner = "root";
      permissions = "u+rx,g+x";
      source = "${cfg.package}/bin/soundmodemconfig";
    };

    users.groups.soundmodem = { };
  };
}
