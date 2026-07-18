{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.honk;

  honk-initdb-script =
    cfg:
    pkgs.writeShellApplication {
      name = "honk-initdb-script";
      runtimeInputs = with pkgs; [ coreutils ];

      text = ''
        PW=$(cat "$CREDENTIALS_DIRECTORY/honk_passwordFile")

        echo -e "${cfg.username}\n''$PW\n${cfg.host}:${toString cfg.port}\n${cfg.servername}" | ${lib.getExe cfg.package} -datadir "$STATE_DIRECTORY" init
      '';
    };
in
{
  options = {
    services.honk = {
      enable = lib.mkEnableOption "the Honk server";
      package = lib.mkPackageOption pkgs "honk" { };

      extraCSS = lib.mkOption {
        default = null;

        description = ''
          An extra CSS file to be loaded by the client.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      extraJS = lib.mkOption {
        default = null;

        description = ''
          An extra JavaScript file to be loaded by the client.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      host = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          The host name or IP address the server should listen to.
        '';

        type = lib.types.str;
      };

      passwordFile = lib.mkOption {
        description = ''
          Password for admin account.
          NOTE: Should be string not a store path, to prevent the password from being world readable
        '';

        type = lib.types.path;
      };

      port = lib.mkOption {
        default = 8080;

        description = ''
          The port the server should listen to.
        '';

        type = lib.types.port;
      };

      servername = lib.mkOption {
        description = ''
          The server name.
        '';

        type = lib.types.str;
      };

      username = lib.mkOption {
        description = ''
          The admin account username.
        '';

        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.username or "" != "";

        message = ''
          You have to define a username for Honk (`services.honk.username`).
        '';
      }
      {
        assertion = cfg.servername or "" != "";

        message = ''
          You have to define a servername for Honk (`services.honk.servername`).
        '';
      }
    ];

    systemd.services.honk = {
      after = [ "network.target" ];
      bindsTo = [ "honk-initdb.service" ];
      description = "Honk server";

      preStart = ''
        mkdir -p $STATE_DIRECTORY/views
        ${lib.optionalString (cfg.extraJS != null) "ln -fs ${cfg.extraJS} $STATE_DIRECTORY/views/local.js"}
        ${lib.optionalString (
          cfg.extraCSS != null
        ) "ln -fs ${cfg.extraCSS} $STATE_DIRECTORY/views/local.css"}
        ${lib.getExe cfg.package} -datadir $STATE_DIRECTORY -viewdir ${cfg.package}/share/honk backup $STATE_DIRECTORY/backup
        ${lib.getExe cfg.package} -datadir $STATE_DIRECTORY -viewdir ${cfg.package}/share/honk upgrade
        ${lib.getExe cfg.package} -datadir $STATE_DIRECTORY -viewdir ${cfg.package}/share/honk cleanup
      '';

      serviceConfig = {
        DynamicUser = true;

        ExecStart = ''
          ${lib.getExe cfg.package} -datadir $STATE_DIRECTORY -viewdir ${cfg.package}/share/honk
        '';

        PrivateTmp = "yes";
        Restart = "on-failure";
        StateDirectory = "honk";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.honk-initdb = {
      before = [ "honk.service" ];
      description = "Honk server database setup";
      requiredBy = [ "honk.service" ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = lib.getExe (honk-initdb-script cfg);

        LoadCredential = [
          "honk_passwordFile:${cfg.passwordFile}"
        ];

        PrivateTmp = true;
        RemainAfterExit = true;
        StateDirectory = "honk";
        Type = "oneshot";
      };

      unitConfig = {
        ConditionPathExists = [
          # Skip this service if the database already exists
          "!%S/honk/honk.db"
        ];
      };
    };
  };

  meta = {
    doc = ./honk.md;
    maintainers = [ ];
  };
}
