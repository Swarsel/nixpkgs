{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.librepods;
in
{
  options = {
    programs.librepods = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to configure system to enable librepods.
          To grant access to a user, it must be part of librepods group:
          `users.users.alice.extraGroups = ["librepods"];`
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ librepods ];

    security.wrappers.librepods = {
      capabilities = "cap_net_admin+ep";
      group = "librepods";
      owner = "root";
      permissions = "u+rx,g+x";
      source = lib.getExe pkgs.librepods;
    };

    users.groups.librepods = { };
  };

  meta.maintainers = with lib.maintainers; [
    thefossguy
    Cameo007
  ];
}
