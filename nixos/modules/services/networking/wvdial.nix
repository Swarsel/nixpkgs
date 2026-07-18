# Global configuration for wvdial.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.environment.wvdial;
in
{
  options = {
    environment.wvdial = {
      dialerDefaults = lib.mkOption {
        default = "";

        description = ''
          Contents of the "Dialer Defaults" section of
          <filename>/etc/wvdial.conf</filename>.
        '';

        example = ''Init1 = AT+CGDCONT=1,"IP","internet.t-mobile"'';
        type = lib.types.str;
      };

      pppDefaults = lib.mkOption {
        default = ''
          noipdefault
          usepeerdns
          defaultroute
          persist
          noauth
        '';

        description = "Default ppp settings for wvdial.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf (cfg.dialerDefaults != "") {
    environment.etc."ppp/peers/wvdial".source = pkgs.writeText "wvdial" cfg.pppDefaults;

    environment.etc."wvdial.conf".source = pkgs.writeText "wvdial.conf" ''
      [Dialer Defaults]
      PPPD PATH = ${pkgs.ppp}/sbin/pppd
      ${config.environment.wvdial.dialerDefaults}
    '';
  };
}
