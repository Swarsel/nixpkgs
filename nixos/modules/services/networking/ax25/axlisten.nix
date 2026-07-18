{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    ;

  inherit (lib.modules)
    mkIf
    ;

  inherit (lib.options)
    mkEnableOption
    mkOption
    mkPackageOption
    ;

  cfg = config.services.ax25.axlisten;
in
{
  options = {

    services.ax25.axlisten = {

      config = mkOption {
        default = "-art";

        description = ''
          Options that will be passed to the axlisten daemon.
        '';

        type = types.str;
      };

      enable = mkEnableOption "AX.25 axlisten daemon";
      package = mkPackageOption pkgs "ax25-apps" { };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.axlisten = {
      after = [ "ax25-axports.target" ];
      description = "AX.25 traffic monitor";
      requires = [ "ax25-axports.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/axlisten ${cfg.config}";
        Type = "exec";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
