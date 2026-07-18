{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.programs.mosh;

in
{
  options.programs.mosh = {
    enable = lib.mkEnableOption "mosh";
    package = lib.mkPackageOption pkgs "mosh" { };

    openFirewall = lib.mkEnableOption "" // {
      default = true;
      description = "Whether to automatically open the necessary ports in the firewall.";
    };

    withUtempter = lib.mkEnableOption "" // {
      default = true;

      description = ''
        Whether to enable libutempter for mosh.

        This is required so that mosh can write to /var/run/utmp (which can be queried with `who` to display currently connected user sessions).
        Note, this will add a guid wrapper for the group utmp!
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall.allowedUDPPortRanges = lib.optional cfg.openFirewall {
      from = 60000;
      to = 61000;
    };

    security.wrappers = lib.mkIf cfg.withUtempter {
      utempter = {
        group = "utmp";
        owner = "root";
        setgid = true;
        setuid = false;
        source = "${pkgs.libutempter}/lib/utempter/utempter";
      };
    };
  };
}
