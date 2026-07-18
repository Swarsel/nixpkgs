{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let

  cfg = config.services.freefall;

in
{

  options.services.freefall = {

    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to protect HP/Dell laptop hard drives (not SSDs) in free fall.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "freefall" { };

    devices = lib.mkOption {
      default = [ "/dev/sda" ];

      description = ''
        Device paths to all internal spinning hard drives.
      '';

      type = lib.types.listOf lib.types.str;
    };

  };

  config =
    let

      mkService =
        dev:
        assert dev != "";
        let
          dev' = utils.escapeSystemdPath dev;
        in
        lib.nameValuePair "freefall-${dev'}" {
          after = [ "${dev'}.device" ];
          description = "Free-fall protection for ${dev}";

          serviceConfig = {
            ExecStart = "${cfg.package}/bin/freefall ${dev}";
            Restart = "on-failure";
            Type = "forking";
          };

          wantedBy = [ "${dev'}.device" ];
        };

    in
    lib.mkIf cfg.enable {

      environment.systemPackages = [ cfg.package ];
      systemd.services = builtins.listToAttrs (map mkService cfg.devices);

    };

}
