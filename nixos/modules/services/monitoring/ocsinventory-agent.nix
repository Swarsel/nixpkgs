{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ocsinventory-agent;

  settingsFormat = pkgs.formats.keyValue {
    mkKeyValue = lib.generators.mkKeyValueDefault { } "=";
  };

in
{
  options = {
    services.ocsinventory-agent = {
      enable = lib.mkEnableOption "OCS Inventory Agent";
      package = lib.mkPackageOption pkgs "ocsinventory-agent" { };

      interval = lib.mkOption {
        default = "daily";

        description = ''
          How often we run the ocsinventory-agent service. Runs by default every daily.

          The format is described in
          {manpage}`systemd.time(7)`.
        '';

        example = "06:00";
        type = lib.types.str;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Configuration for /etc/ocsinventory-agent/ocsinventory-agent.cfg.

          Refer to
          {manpage}`ocsinventory-agent(1)` for available options.
        '';

        example = {
          debug = true;
          server = "https://ocsinventory.localhost:8080/ocsinventory";
          tag = "01234567890123";
        };

        type = lib.types.submodule {
          options = {
            ca = lib.mkOption {
              default = config.security.pki.caBundle;
              defaultText = lib.literalExpression "config.security.pki.caBundle";

              description = ''
                Path to CA certificates file in PEM format, for server
                SSL certificate validation.
              '';

              type = lib.types.path;
            };

            debug = lib.mkEnableOption "debug mode";

            local = lib.mkOption {
              default = null;

              description = ''
                If specified, the OCS Inventory Agent will run in offline mode
                and the resulting inventory file will be stored in the specified path.
              '';

              example = "/var/lib/ocsinventory-agent/reports";
              type = lib.types.nullOr lib.types.path;
            };

            server = lib.mkOption {
              default = null;

              description = ''
                The URI of the OCS Inventory server where to send the inventory file.

                This option is ignored if {option}`services.ocsinventory-agent.settings.local` is set.
              '';

              example = "https://ocsinventory.localhost:8080/ocsinventory";
              type = lib.types.nullOr lib.types.str;
            };

            tag = lib.mkOption {
              default = null;
              description = "Tag for the generated inventory.";
              example = "01234567890123";
              type = lib.types.nullOr lib.types.str;
            };
          };

          freeformType = settingsFormat.type.nestedTypes.elemType;
        };
      };
    };
  };

  config =
    let
      configFile = settingsFormat.generate "ocsinventory-agent.cfg" cfg.settings;

    in
    lib.mkIf cfg.enable {
      # Path of the configuration file is hard-coded and cannot be changed
      # https://github.com/OCSInventory-NG/UnixAgent/blob/v2.10.0/lib/Ocsinventory/Agent/Config.pm#L78
      #
      environment.etc."ocsinventory-agent/ocsinventory-agent.cfg".source = configFile;

      systemd.services.ocsinventory-agent = {
        after = [ "network.target" ];
        description = "OCS Inventory Agent service";
        reloadTriggers = [ configFile ];

        serviceConfig = {
          ConfigurationDirectory = "ocsinventory-agent";
          ExecStart = lib.getExe cfg.package;
          StateDirectory = "ocsinventory-agent";
        };

        wantedBy = [ "multi-user.target" ];
      };

      systemd.timers.ocsinventory-agent = {
        description = "Launch OCS Inventory Agent regularly";

        timerConfig = {
          AccuracySec = "1h";
          OnCalendar = cfg.interval;
          Persistent = true;
          RandomizedDelaySec = 240;
          Unit = "ocsinventory-agent.service";
        };

        wantedBy = [ "timers.target" ];
      };
    };

  meta = {
    doc = ./ocsinventory-agent.md;
    maintainers = with lib.maintainers; [ anthonyroussel ];
  };
}
