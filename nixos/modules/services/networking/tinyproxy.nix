{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.tinyproxy;
  mkValueStringTinyproxy =
    v:
    if true == v then
      "yes"
    else if false == v then
      "no"
    else if lib.types.path.check v then
      ''"${v}"''
    else
      lib.generators.mkValueStringDefault { } v;
  mkKeyValueTinyproxy =
    {
      mkValueString ? lib.mkValueStringDefault { },
    }:
    sep: k: v:
    if null == v then "" else "${lib.strings.escape [ sep ] k}${sep}${mkValueString v}";

  settingsFormat = (
    pkgs.formats.keyValue {
      listsAsDuplicateKeys = true;

      mkKeyValue = mkKeyValueTinyproxy {
        mkValueString = mkValueStringTinyproxy;
      } " ";
    }
  );
  configFile = settingsFormat.generate "tinyproxy.conf" cfg.settings;

in
{

  options = {
    services.tinyproxy = {
      enable = lib.mkEnableOption "Tinyproxy daemon";
      package = lib.mkPackageOption pkgs "tinyproxy" { };

      settings = lib.mkOption {
        default = { };
        description = "Configuration for [tinyproxy](https://tinyproxy.github.io/).";

        example = lib.literalExpression ''
          {
            Port 8888;
            Listen 127.0.0.1;
            Timeout 600;
            Allow 127.0.0.1;
            Anonymous = ['"Host"' '"Authorization"'];
            ReversePath = '"/example/" "http://www.example.com/"';
          }
        '';

        type = lib.types.submodule (
          { name, ... }:
          {
            options = {
              Anonymous = lib.mkOption {
                default = [ ];

                description = ''
                  If an `Anonymous` keyword is present, then anonymous proxying is enabled. The headers listed with `Anonymous` are allowed through, while all others are denied. If no Anonymous keyword is present, then all headers are allowed through. You must include quotes around the headers.
                '';

                type = lib.types.listOf lib.types.str;
              };

              Filter = lib.mkOption {
                default = null;

                description = ''
                  Tinyproxy supports filtering of web sites based on URLs or domains. This option specifies the location of the file containing the filter rules, one rule per line.
                '';

                type = lib.types.nullOr lib.types.path;
              };

              Listen = lib.mkOption {
                default = "127.0.0.1";

                description = ''
                  Specify which address to listen to.
                '';

                type = lib.types.nullOr lib.types.str;
              };

              Port = lib.mkOption {
                default = 8888;

                description = ''
                  Specify which port to listen to.
                '';

                type = lib.types.port;
              };
            };

            freeformType = settingsFormat.type;
          }
        );
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.tinyproxy = {
      after = [ "network.target" ];
      description = "TinyProxy daemon";

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGHUP $MAINPID";
        ExecStart = "${lib.getExe cfg.package} -d -c ${configFile}";
        Group = "tinyproxy";
        KillSignal = "SIGINT";
        Restart = "on-failure";
        TimeoutStopSec = "30s";
        Type = "simple";
        User = "tinyproxy";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.tinyproxy = { };

    users.users.tinyproxy = {
      group = "tinyproxy";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [ tcheronneau ];
}
