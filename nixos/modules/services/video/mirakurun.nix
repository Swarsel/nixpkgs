{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.mirakurun;
  mirakurun = pkgs.mirakurun;
  username = config.users.users.mirakurun.name;
  groupname = config.users.users.mirakurun.group;
  settingsFmt = pkgs.formats.yaml { };

  polkitRule = pkgs.writeTextDir "share/polkit-1/rules.d/10-mirakurun.rules" ''
    polkit.addRule(function (action, subject) {
      if (
        (action.id == "org.debian.pcsc-lite.access_pcsc" ||
          action.id == "org.debian.pcsc-lite.access_card") &&
        subject.user == "${username}"
      ) {
        return polkit.Result.YES;
      }
    });
  '';
in
{
  options = {
    services.mirakurun = {
      enable = mkEnableOption "the Mirakurun DVR Tuner Server";

      allowSmartCardAccess = mkOption {
        default = true;

        description = ''
          Install polkit rules to allow Mirakurun to access smart card readers
          which is commonly used along with tuner devices.
        '';

        type = types.bool;
      };

      channelSettings = mkOption {
        default = null;

        description = ''
          Options which are added to channels.yml. If none is specified, it
          will automatically be generated at runtime.

          Documentation:
          <https://github.com/Chinachu/Mirakurun/blob/master/doc/Configuration.md>
        '';

        example = literalExpression ''
          [
            {
              name = "channel";
              types = "GR";
              channel = "0";
            }
          ];
        '';

        type = with types; nullOr settingsFmt.type;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Open ports in the firewall for Mirakurun.

          ::: {.warning}
          Exposing Mirakurun to the open internet is generally advised
          against. Only use it inside a trusted local network, or
          consider putting it behind a VPN if you want remote access.
          :::
        '';

        type = types.bool;
      };

      port = mkOption {
        default = 40772;

        description = ''
          Port to listen on. If `null`, it won't listen on
          any port.
        '';

        type = with types; nullOr port;
      };

      serverSettings = mkOption {
        default = { };

        description = ''
          Options for server.yml.

          Documentation:
          <https://github.com/Chinachu/Mirakurun/blob/master/doc/Configuration.md>
        '';

        example = literalExpression ''
          {
            highWaterMark = 25165824;
            overflowTimeLimit = 30000;
          };
        '';

        type = settingsFmt.type;
      };

      tunerSettings = mkOption {
        default = null;

        description = ''
          Options which are added to tuners.yml. If none is specified, it will
          automatically be generated at runtime.

          Documentation:
          <https://github.com/Chinachu/Mirakurun/blob/master/doc/Configuration.md>
        '';

        example = literalExpression ''
          [
            {
              name = "tuner-name";
              types = [ "GR" "BS" "CS" "SKY" ];
              dvbDevicePath = "/dev/dvb/adapterX/dvrX";
            }
          ];
        '';

        type = with types; nullOr settingsFmt.type;
      };

      unixSocket = mkOption {
        default = "/var/run/mirakurun/mirakurun.sock";

        description = ''
          Path to unix socket to listen on. If `null`, it
          won't listen on any unix sockets.
        '';

        type = with types; nullOr path;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc = {
      "mirakurun/channels.yml" = mkIf (cfg.channelSettings != null) {
        group = groupname;
        mode = "0644";
        source = settingsFmt.generate "channels.yml" cfg.channelSettings;
        user = username;
      };

      "mirakurun/server.yml".source = settingsFmt.generate "server.yml" cfg.serverSettings;

      "mirakurun/tuners.yml" = mkIf (cfg.tunerSettings != null) {
        group = groupname;
        mode = "0644";
        source = settingsFmt.generate "tuners.yml" cfg.tunerSettings;
        user = username;
      };
    };

    environment.systemPackages = [ mirakurun ] ++ optional cfg.allowSmartCardAccess polkitRule;

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = mkIf (cfg.port != null) [ cfg.port ];
    };

    services.mirakurun.serverSettings = {
      logLevel = mkDefault 2;
      path = mkIf (cfg.unixSocket != null) cfg.unixSocket;
      port = mkIf (cfg.port != null) cfg.port;
    };

    systemd.services.mirakurun = {
      after = [ "network.target" ];
      description = mirakurun.meta.description;

      environment = {
        CHANNELS_CONFIG_PATH = "/etc/mirakurun/channels.yml";
        LOGO_DATA_DIR_PATH = "/var/lib/mirakurun/logos";
        NODE_ENV = "production";
        PROGRAMS_DB_PATH = "/var/lib/mirakurun/programs.json";
        SERVER_CONFIG_PATH = "/etc/mirakurun/server.yml";
        SERVICES_DB_PATH = "/var/lib/mirakurun/services.json";
        TUNERS_CONFIG_PATH = "/etc/mirakurun/tuners.yml";
      };

      restartTriggers =
        let
          getconf = target: config.environment.etc."mirakurun/${target}.yml".source;
          targets = [
            "server"
          ]
          ++ optional (cfg.tunerSettings != null) "tuners"
          ++ optional (cfg.channelSettings != null) "channels";
        in
        (map getconf targets);

      serviceConfig = {
        CacheDirectory = "mirakurun";
        ExecStart = "${mirakurun}/bin/mirakurun start";
        Group = groupname;
        IOSchedulingClass = "realtime";
        IOSchedulingPriority = 7;
        Nice = -10;
        RuntimeDirectory = "mirakurun";
        StateDirectory = "mirakurun";
        User = username;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-mirakurun"."/etc/mirakurun".d = {
      group = groupname;
      user = username;
    };

    users.users.mirakurun = {
      description = "Mirakurun user";
      group = "video";
      # npm insists on creating ~/.npm
      home = "/var/cache/mirakurun";
      isSystemUser = true;
    };
  };
}
