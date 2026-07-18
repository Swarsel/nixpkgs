{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  xcfg = config.services.xserver;
  cfg = xcfg.desktopManager.cde;
in
{
  options.services.xserver.desktopManager.cde = {
    enable = mkEnableOption "Common Desktop Environment";

    extraPackages = mkOption {
      default = with pkgs; [
        xclock
        bitmap
        xlsfonts
        xfd
        xrefresh
        xload
        xwininfo
        xdpyinfo
        xwd
        xwud
      ];

      defaultText = literalExpression ''
        with pkgs; [
          xclock bitmap xlsfonts xfd xrefresh xload xwininfo xdpyinfo xwd xwud
        ]
      '';

      description = ''
        Extra packages to be installed system wide.
      '';

      type = with types; listOf package;
    };
  };

  config = mkIf (xcfg.enable && cfg.enable) {
    environment.systemPackages = cfg.extraPackages;

    security.wrappers = {
      dtmail = {
        group = "mail";
        owner = "root";
        setgid = true;
        source = "${pkgs.cdesktopenv}/bin/dtmail";
      };
    };

    services.rpcbind.enable = true;
    services.xinetd.enable = true;

    services.xinetd.services = [
      {
        extraConfig = ''
          type  = RPC UNLISTED
          rpc_number  = 100068
          rpc_version = 2-5
          only_from   = 127.0.0.1/0
        '';

        name = "cmsd";
        protocol = "udp";
        server = "${pkgs.cdesktopenv}/bin/rpc.cmsd";
        user = "root";
      }
    ];

    services.xserver.desktopManager.session = [
      {
        name = "CDE";

        start = ''
          exec ${pkgs.cdesktopenv}/bin/Xsession
        '';
      }
    ];

    systemd.tmpfiles.settings."10-cde" = {
      "/var/dt".d.mode = "0755";
      "/var/dt/appconfig".d.mode = "0755";
      "/var/dt/appconfig/appmanager".d.mode = "1777";
      "/var/dt/tmp".d.mode = "1777";
    };

    users.groups.mail = { };
  };

  meta.maintainers = [ ];
}
