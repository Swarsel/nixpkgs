{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  cfg = config.programs.yubikey-touch-detector;
in
{
  options = {
    programs.yubikey-touch-detector = {

      enable = lib.mkEnableOption "yubikey-touch-detector";

      libnotify = lib.mkOption {
        # This used to be true previously and using libnotify would be a sane default.
        default = true;

        description = ''
          If set to true, yubikey-touch-detctor will send notifications using libnotify
        '';

        type = types.bool;
      };

      unixSocket = lib.mkOption {
        default = true;

        description = ''
          If set to true, yubikey-touch-detector will send notifications to a unix socket
        '';

        type = types.bool;
      };

      verbose = lib.mkOption {
        default = false;

        description = ''
          Enables verbose logging
        '';

        type = types.bool;
      };

    };
  };

  config = lib.mkIf cfg.enable {
    systemd.packages = [ pkgs.yubikey-touch-detector ];

    systemd.user.services.yubikey-touch-detector = {
      environment = {
        YUBIKEY_TOUCH_DETECTOR_LIBNOTIFY = toString cfg.libnotify;
        YUBIKEY_TOUCH_DETECTOR_NOSOCKET = toString (!cfg.unixSocket);
        YUBIKEY_TOUCH_DETECTOR_VERBOSE = toString cfg.verbose;
      };

      partOf = [ "graphical-session.target" ];
      path = [ pkgs.gnupg ];
      wantedBy = [ "graphical-session.target" ];
    };

    systemd.user.sockets.yubikey-touch-detector = {
      wantedBy = [ "sockets.target" ];
    };
  };
}
