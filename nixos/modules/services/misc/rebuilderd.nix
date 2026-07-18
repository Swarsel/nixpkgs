{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.services.rebuilderd;

  format = pkgs.formats.toml { };
  settings = lib.attrsets.filterAttrs (n: v: v != null) cfg.settings;
  configFile = format.generate "rebuilderd.conf" settings;
in
{
  options.services.rebuilderd = {
    enable = mkEnableOption "rebuilderd service for independent verification of binary packages";
    package = mkPackageOption pkgs "rebuilderd" { };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for rebuilderd (rebuilderd.conf)
      '';

      type = lib.types.submodule {
        freeformType = format.type;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.rebuilderd = {
      after = [
        "network.target"
      ];

      description = "Independent verification of binary packages";

      environment = {
        REBUILDERD_COOKIE_PATH = "/var/lib/rebuilderd/auth-cookie";
      };

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/rebuilderd --config ${configFile}";
        StateDirectory = "rebuilderd";
        WorkingDirectory = "/var/lib/rebuilderd";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
