{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.weylus;
in
{
  options.programs.weylus = with lib.types; {
    enable = lib.mkEnableOption "weylus, which turns your smart phone into a graphic tablet/touch screen for your computer";
    package = lib.mkPackageOption pkgs "weylus" { };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open ports needed for the functionality of the program.
      '';

      type = bool;
    };

    users = lib.mkOption {
      default = [ ];

      description = ''
        To enable stylus and multi-touch support, the user you're going to use must be added to this list.
        These users can synthesize input events system-wide, even when another user is logged in - untrusted users should not be added.
      '';

      type = listOf str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    hardware.uinput.enable = true;

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        1701
        9001
      ];
    };

    users.groups.uinput.members = cfg.users;
  };
}
