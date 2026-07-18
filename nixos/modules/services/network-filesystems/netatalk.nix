{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.netatalk;
  settingsFormat = pkgs.formats.ini { };
  afpConfFile = settingsFormat.generate "afp.conf" cfg.settings;
in
{
  imports = (
    map
      (
        option:
        lib.mkRemovedOptionModule [
          "services"
          "netatalk"
          option
        ] "This option was removed in favor of `services.netatalk.settings`."
      )
      [
        "extraConfig"
        "homes"
        "volumes"
      ]
  );

  options = {
    services.netatalk = {

      enable = lib.mkEnableOption "the Netatalk AFP fileserver";

      extmap = lib.mkOption {
        default = "";

        description = ''
          File name extension mappings.
          See {manpage}`extmap.conf(5)`. for more information.
        '';

        type = lib.types.lines;
      };

      port = lib.mkOption {
        default = 548;
        description = "TCP port to be used for AFP.";
        type = lib.types.port;
      };

      settings = lib.mkOption {
        inherit (settingsFormat) type;
        default = { };

        description = ''
          Configuration for Netatalk. See
          {manpage}`afp.conf(5)`.
        '';

        example = {
          Global = {
            "uam list" = "uams_guest.so";
          };

          Homes = {
            "basedir regex" = "/home";
            path = "afp-data";
          };

          example-volume = {
            path = "/srv/volume";
            "read only" = true;
          };
        };
      };

    };
  };

  config = lib.mkIf cfg.enable {

    security.pam.services.netatalk.unixAuth = true;

    services.netatalk.settings.Global = {
      "afp port" = toString cfg.port;
      "extmap file" = "${pkgs.writeText "extmap.conf" cfg.extmap}";
    };

    systemd.services.netatalk = {
      after = [
        "network.target"
        "avahi-daemon.service"
      ];

      description = "Netatalk AFP fileserver for Macintosh clients";
      path = [ pkgs.netatalk ];

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP  $MAINPID";
        ExecStart = "${pkgs.netatalk}/sbin/netatalk -F ${afpConfFile}";
        ExecStop = "${pkgs.coreutils}/bin/kill -TERM $MAINPID";
        GuessMainPID = "no";
        PIDFile = "/run/lock/netatalk";
        Restart = "always";
        RestartSec = 1;
        StateDirectory = [ "netatalk/CNID" ];
        Type = "forking";
      };

      unitConfig.Documentation = "man:afp.conf(5) man:netatalk(8) man:afpd(8) man:cnid_metad(8) man:cnid_dbd(8)";
      wantedBy = [ "multi-user.target" ];

    };

  };

}
