{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus.alertmanagerIrcRelay;

  configFormat = pkgs.formats.yaml { };
  configFile = configFormat.generate "alertmanager-irc-relay.yml" cfg.settings;
in
{
  options.services.prometheus.alertmanagerIrcRelay = {
    enable = lib.mkEnableOption "Alertmanager IRC Relay";
    package = lib.mkPackageOption pkgs "alertmanager-irc-relay" { };

    extraFlags = lib.mkOption {
      default = [ ];
      description = "Extra command line options to pass to alertmanager-irc-relay.";
      type = lib.types.listOf lib.types.str;
    };

    settings = lib.mkOption {
      description = ''
        Configuration for Alertmanager IRC Relay as a Nix attribute set.
        For a reference, check out the
        [example configuration](https://github.com/google/alertmanager-irc-relay#configuring-and-running-the-bot)
        and the
        [source code](https://github.com/google/alertmanager-irc-relay/blob/master/config.go).

        Note: The webhook's URL MUST point to the IRC channel where the message
        should be posted. For `#mychannel` from the example, this would be
        `http://localhost:8080/mychannel`.
      '';

      example = lib.literalExpression ''
        {
          http_host = "localhost";
          http_port = 8000;

          irc_host = "irc.example.com";
          irc_port = 7000;
          irc_nickname = "myalertbot";

          irc_channels = [
            { name = "#mychannel"; }
          ];
        }
      '';

      type = configFormat.type;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.alertmanager-irc-relay = {
      after = [ "network-online.target" ];
      description = "Alertmanager IRC Relay";

      serviceConfig = {
        DynamicUser = true;

        ExecStart = ''
          ${cfg.package}/bin/alertmanager-irc-relay \
          -config ${configFile} \
          ${lib.escapeShellArgs cfg.extraFlags}
        '';

        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateIPC = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = "tmpfs";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        SystemCallFilter = [
          "@system-service"
          "~@cpu-emulation"
          "~@privileged"
          "~@reboot"
          "~@setuid"
          "~@swap"
        ];
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = [ ];
}
