{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.freeswitch;
  pkg = cfg.package;
  configDirectory = pkgs.runCommand "freeswitch-config-d" { } ''
    mkdir -p $out
    cp -rT ${cfg.configTemplate} $out
    chmod -R +w $out
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (fileName: filePath: ''
        mkdir -p $out/$(dirname ${fileName})
        cp ${filePath} $out/${fileName}
      '') cfg.configDir
    )}
  '';
  configPath = if cfg.enableReload then "/etc/freeswitch" else configDirectory;
in
{
  options = {
    services.freeswitch = {
      enable = lib.mkEnableOption "FreeSWITCH";
      package = lib.mkPackageOption pkgs "freeswitch" { };

      configDir = lib.mkOption {
        default = { };

        description = ''
          Override file in FreeSWITCH config template directory.
          Each top-level attribute denotes a file path in the configuration directory, its value is the file path.
          See [FreeSWITCH documentation](https://freeswitch.org/confluence/display/FREESWITCH/Default+Configuration) for more info.
          Also check available templates in [FreeSWITCH repository](https://github.com/signalwire/freeswitch/tree/master/conf).
        '';

        example = lib.literalExpression ''
          {
            "freeswitch.xml" = ./freeswitch.xml;
            "dialplan/default.xml" = pkgs.writeText "dialplan-default.xml" '''
              [xml lines]
            ''';
          }
        '';

        type = with lib.types; attrsOf path;
      };

      configTemplate = lib.mkOption {
        default = "${config.services.freeswitch.package}/share/freeswitch/conf/vanilla";
        defaultText = lib.literalExpression ''"''${config.services.freeswitch.package}/share/freeswitch/conf/vanilla"'';

        description = ''
          Configuration template to use.
          See available templates in [FreeSWITCH repository](https://github.com/signalwire/freeswitch/tree/master/conf).
          You can also set your own configuration directory.
        '';

        example = lib.literalExpression ''"''${config.services.freeswitch.package}/share/freeswitch/conf/minimal"'';
        type = lib.types.path;
      };

      enableReload = lib.mkOption {
        default = false;

        description = ''
          Issue the `reloadxml` command to FreeSWITCH when configuration directory changes (instead of restart).
          See [FreeSWITCH documentation](https://freeswitch.org/confluence/display/FREESWITCH/Reloading) for more info.
          The configuration directory is exposed at {file}`/etc/freeswitch`.
          See also `systemd.services.*.restartIfChanged`.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc.freeswitch = lib.mkIf cfg.enableReload {
      source = configDirectory;
    };

    environment.systemPackages = [ pkg ];

    systemd.services.freeswitch = {
      after = [ "network.target" ];
      description = "Free and open-source application server for real-time communication";

      serviceConfig = {
        CPUSchedulingPolicy = "fifo";
        DynamicUser = true;
        ExecReload = "${pkg}/bin/fs_cli -x reloadxml";

        ExecStart = "${pkg}/bin/freeswitch -nf \\
          -mod ${pkg}/lib/freeswitch/mod \\
          -conf ${configPath} \\
          -base /var/lib/freeswitch";

        Restart = "on-failure";
        RestartSec = "5s";
        StateDirectory = "freeswitch";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.freeswitch-config-reload = lib.mkIf cfg.enableReload {
      before = [ "freeswitch.service" ];
      restartTriggers = [ configDirectory ];

      serviceConfig = {
        ExecStart = "/run/current-system/systemd/bin/systemctl try-reload-or-restart freeswitch.service";
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
