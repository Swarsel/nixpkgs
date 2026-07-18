{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.programs._1password;

in
{
  imports = [
    (lib.mkRemovedOptionModule [ "programs" "_1password" "gid" ] ''
      A preallocated GID will be used instead.
    '')
  ];

  options = {
    programs._1password = {
      enable = lib.mkEnableOption "the 1Password CLI tool";

      package = lib.mkPackageOption pkgs "1Password CLI" {
        default = [ "_1password-cli" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    security.wrappers = {
      "op" = {
        group = "onepassword-cli";
        owner = "root";
        setgid = true;
        setuid = false;
        source = "${cfg.package}/bin/op";
      };
    };

    users.groups.onepassword-cli.gid = config.ids.gids.onepassword-cli;
  };
}
