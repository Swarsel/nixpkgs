{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.ckb-next;

in
{
  imports = [
    (lib.mkRenamedOptionModule [ "hardware" "ckb" "enable" ] [ "hardware" "ckb-next" "enable" ])
    (lib.mkRenamedOptionModule [ "hardware" "ckb" "package" ] [ "hardware" "ckb-next" "package" ])
  ];

  options.hardware.ckb-next = {
    enable = lib.mkEnableOption "the Corsair keyboard/mouse driver";
    package = lib.mkPackageOption pkgs "ckb-next" { };

    gid = lib.mkOption {
      default = null;

      description = ''
        Limit access to the ckb daemon to a particular group.
      '';

      example = 100;
      type = lib.types.nullOr lib.types.int;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.ckb-next = {
      description = "Corsair Keyboards and Mice Daemon";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/ckb-next-daemon ${
          lib.optionalString (cfg.gid != null) "--gid=${toString cfg.gid}"
        }";

        Restart = "on-failure";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = [ ];
  };
}
