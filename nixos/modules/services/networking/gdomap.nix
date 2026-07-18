{
  config,
  lib,
  pkgs,
  ...
}:
{
  #
  # interface
  #
  options = {
    services.gdomap = {
      enable = lib.mkEnableOption "GNUstep Distributed Objects name server";
    };
  };

  #
  # implementation
  #
  config = lib.mkIf config.services.gdomap.enable {
    # NOTE: gdomap runs as root
    # TODO: extra user for gdomap?
    systemd.services.gdomap = {
      after = [ "network.target" ];
      description = "gdomap server";
      path = [ pkgs.gnustep-base ];
      serviceConfig.ExecStart = "${pkgs.gnustep-base}/bin/gdomap -f";
      wantedBy = [ "multi-user.target" ];
    };
  };
}
