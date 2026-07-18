{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs._1password-gui;
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "programs" "_1password-gui" "gid" ] ''
      A preallocated GID will be used instead.
    '')
  ];

  options = {
    programs._1password-gui = {
      enable = lib.mkEnableOption "the 1Password GUI application";

      package =
        lib.mkPackageOption pkgs "1Password GUI" {
          default = [ "_1password-gui" ];
        }
        // {
          apply =
            pkg:
            pkg.override {
              inherit (cfg) polkitPolicyOwners;
            };
        };

      polkitPolicyOwners = lib.mkOption {
        default = [ ];

        description = ''
          A list of users who should be able to integrate 1Password with polkit-based authentication mechanisms.
        '';

        example = lib.literalExpression ''["user1" "user2" "user3"]'';
        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    security.wrappers = {
      "1Password-BrowserSupport" = {
        group = "onepassword";
        owner = "root";
        setgid = true;
        setuid = false;
        source = "${cfg.package}/share/1password/1Password-BrowserSupport";
      };
    };

    users.groups.onepassword.gid = config.ids.gids.onepassword;
  };
}
