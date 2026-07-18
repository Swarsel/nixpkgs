{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.virtualisation.appvm;

in
{

  options = {
    virtualisation.appvm = {
      enable = mkOption {
        default = false;

        description = ''
          This enables AppVMs and related virtualisation settings.
        '';

        type = types.bool;
      };

      user = mkOption {
        description = ''
          AppVM user login. Currently only AppVMs are supported for a single user only.
        '';

        type = types.str;
      };
    };

  };

  config = mkIf cfg.enable {
    users.users."${cfg.user}" = {
      extraGroups = [ "libvirtd" ];
      packages = [ pkgs.appvm ];
    };

    virtualisation.libvirtd = {
      enable = true;

      qemu.verbatimConfig = ''
        namespaces = []
        user = "${cfg.user}"
        group = "users"
        remember_owner = 0
      '';
    };

  };

}
