{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.mjpg-streamer;

in
{

  options = {

    services.mjpg-streamer = {

      enable = mkEnableOption "mjpg-streamer webcam streamer";
      package = mkPackageOption pkgs "mjpg-streamer" { };

      group = mkOption {
        default = "video";
        description = "mjpg-streamer group name.";
        type = types.str;
      };

      inputPlugin = mkOption {
        default = "input_uvc.so";

        description = ''
          Input plugin. See plugins documentation for more information.
        '';

        type = types.str;
      };

      outputPlugin = mkOption {
        default = "output_http.so -w @www@ -n -p 5050";

        description = ''
          Output plugin. `@www@` is substituted for default mjpg-streamer www directory.
          See plugins documentation for more information.
        '';

        type = types.str;
      };

      user = mkOption {
        default = "mjpg-streamer";
        description = "mjpg-streamer user name.";
        type = types.str;
      };

    };

  };

  config = mkIf cfg.enable {

    systemd.services.mjpg-streamer = {
      description = "mjpg-streamer webcam streamer";

      script = ''
        IPLUGIN="${cfg.inputPlugin}"
        OPLUGIN="${cfg.outputPlugin}"
        OPLUGIN="''${OPLUGIN//@www@/${pkgs.mjpg-streamer}/share/mjpg-streamer/www}"
        exec ${lib.getExe cfg.package} -i "$IPLUGIN" -o "$OPLUGIN"
      '';

      serviceConfig = {
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = 1;
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.users = optionalAttrs (cfg.user == "mjpg-streamer") {
      mjpg-streamer = {
        group = cfg.group;
        uid = config.ids.uids.mjpg-streamer;
      };
    };

  };

}
