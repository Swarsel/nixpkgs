{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.shairport-sync;
  configFormat = pkgs.formats.libconfig { };
  configFile = configFormat.generate "shairport-sync.conf" cfg.settings;
in

{

  ###### interface

  options = {

    services.shairport-sync = {

      enable = mkOption {
        default = false;

        description = ''
          Enable the shairport-sync daemon.

          Running with a local system-wide or remote pulseaudio server
          is recommended.
        '';

        type = types.bool;
      };

      package = lib.options.mkPackageOption pkgs "shairport-sync" { };

      arguments = mkOption {
        default = "";

        description = ''
          Arguments to pass to the daemon. Defaults to a local pulseaudio
          server.
        '';

        type = types.str;
      };

      group = mkOption {
        default = "shairport";

        description = ''
          Group account name under which to run shairport-sync. The account
          will be created.
        '';

        type = types.str;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Whether to automatically open ports in the firewall.
        '';

        type = types.bool;
      };

      settings = mkOption {
        default = {
          diagnostics.log_verbosity = 1;
          general.output_backend = "pulseaudio";
        };

        description = ''
          Configuration options for Shairport-Sync.

          See the example [shairport-sync.conf][example-file] for possible options.

          [example-file]: https://github.com/mikebrady/shairport-sync/blob/master/scripts/shairport-sync.conf
        '';

        example = {
          general = {
            name = "NixOS Shairport";
            output_backend = "pipewire";
          };

          metadata = {
            cover_art_cache_directory = "/tmp/shairport-sync/.cache/coverart";
            enabled = "yes";
            include_cover_art = "yes";
            pipe_name = "/tmp/shairport-sync-metadata";
            pipe_timeout = 5000;
          };

          mqtt = {
            enabled = "yes";
            hostname = "mqtt.server.domain.example";
            port = 1883;
            publish_cover = "yes";
            publish_parsed = "yes";
          };
        };

        type = configFormat.type;
      };

      user = mkOption {
        default = "shairport";

        description = ''
          User account name under which to run shairport-sync. The account
          will be created.
        '';

        type = types.str;
      };

    };

  };

  ###### implementation

  config = mkIf config.services.shairport-sync.enable {
    assertions = [
      {
        assertion = config.services.shairport-sync.settings.general.output_backend or null != "pw";
        message = "shairport-sync 5.0 renamed the pipewire backend from 'pw' to 'pipewire'";
      }
      {
        assertion = config.services.shairport-sync.settings.general.output_backend or null != "pa";
        message = "shairport-sync 5.0 renamed the pulseaudio backend from 'pa' to 'pulseaudio'";
      }
    ];

    environment = {
      etc."shairport-sync.conf".source = configFile;
      systemPackages = [ cfg.package ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 5000 ];

      allowedUDPPortRanges = [
        {
          from = 6001;
          to = 6011;
        }
      ];
    };

    services.avahi.enable = true;
    services.avahi.publish.enable = true;
    services.avahi.publish.userServices = true;

    services.shairport-sync.settings = {
      diagnostics.log_verbosity = lib.mkDefault 1;
      general.output_backend = lib.mkDefault "pulseaudio";
    };

    systemd.services.shairport-sync = {
      after = [
        "network.target"
        "avahi-daemon.service"
      ];

      description = "shairport-sync";

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} ${cfg.arguments}";
        Group = cfg.group;
        Restart = "on-failure";
        RuntimeDirectory = "shairport-sync";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups.${cfg.group} = { };

      users.${cfg.user} = {
        createHome = true;
        description = "Shairport user";

        extraGroups = [
          "audio"
        ]
        ++ optional (config.services.pulseaudio.enable || config.services.pipewire.pulse.enable) "pulse";

        group = cfg.group;
        home = "/var/lib/shairport-sync";
        isSystemUser = true;
      };
    };
  };

}
