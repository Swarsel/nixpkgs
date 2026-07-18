{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.telegraf;

  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "config.toml" cfg.extraConfig;
in
{
  ###### interface
  options = {
    services.telegraf = {
      enable = lib.mkEnableOption "telegraf server";
      package = lib.mkPackageOption pkgs "telegraf" { };

      environmentFiles = lib.mkOption {
        default = [ ];

        description = ''
          File to load as environment file. Environment variables from this file
          will be interpolated into the config file using envsubst with this
          syntax: `$ENVIRONMENT` or `''${VARIABLE}`.
          This is useful to avoid putting secrets into the nix store.
        '';

        example = [ "/run/keys/telegraf.env" ];
        type = lib.types.listOf lib.types.path;
      };

      extraConfig = lib.mkOption {
        default = { };
        description = "Extra configuration options for telegraf";

        example = {
          inputs.statsd = {
            delete_timings = true;
            service_address = ":8125";
          };

          outputs.influxdb = {
            database = "telegraf";
            urls = [ "http://localhost:8086" ];
          };
        };

        type = settingsFormat.type;
      };
    };
  };

  ###### implementation
  config = lib.mkIf config.services.telegraf.enable {
    services.telegraf.extraConfig = {
      inputs = { };
      outputs = { };
    };

    systemd.services.telegraf =
      let
        finalConfigFile =
          if config.services.telegraf.environmentFiles == [ ] then
            configFile
          else
            "/var/run/telegraf/config.toml";
      in
      {
        after = [ "network-online.target" ];
        description = "Telegraf Agent";

        path =
          lib.optional (config.services.telegraf.extraConfig.inputs ? procstat) pkgs.procps
          ++ lib.optional (config.services.telegraf.extraConfig.inputs ? ping) pkgs.iputils;

        serviceConfig = {
          # for ping probes
          AmbientCapabilities = [ "CAP_NET_RAW" ];
          EnvironmentFile = config.services.telegraf.environmentFiles;
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          ExecStart = "${cfg.package}/bin/telegraf -config ${finalConfigFile}";

          ExecStartPre = lib.optional (config.services.telegraf.environmentFiles != [ ]) (
            pkgs.writeShellScript "pre-start" ''
              umask 077
              ${pkgs.envsubst}/bin/envsubst -i "${configFile}" > /var/run/telegraf/config.toml
            ''
          );

          Group = "telegraf";
          Restart = "on-failure";
          RuntimeDirectory = "telegraf";
          User = "telegraf";
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      };

    users.groups.telegraf = { };

    users.users.telegraf = {
      description = "telegraf daemon user";
      group = "telegraf";
      uid = config.ids.uids.telegraf;
    };
  };
}
