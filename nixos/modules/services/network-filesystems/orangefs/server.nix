{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.orangefs.server;

  aliases = lib.attrNames cfg.servers;

  # Maximum handle number is 2^63
  maxHandle = 9223372036854775806;

  # One range of handles for each meta/data instance
  handleStep = maxHandle / (lib.length aliases) / 2;

  fileSystems = lib.mapAttrsToList (name: fs: ''
    <FileSystem>
      Name ${name}
      ID ${toString fs.id}
      RootHandle ${toString fs.rootHandle}

      ${fs.extraConfig}

      <MetaHandleRanges>
      ${lib.concatStringsSep "\n" (
        lib.imap0 (
          i: alias:
          let
            begin = i * handleStep + 3;
            end = begin + handleStep - 1;
          in
          "Range ${alias} ${toString begin}-${toString end}"
        ) aliases
      )}
      </MetaHandleRanges>

      <DataHandleRanges>
      ${lib.concatStringsSep "\n" (
        lib.imap0 (
          i: alias:
          let
            begin = i * handleStep + 3 + (lib.length aliases) * handleStep;
            end = begin + handleStep - 1;
          in
          "Range ${alias} ${toString begin}-${toString end}"
        ) aliases
      )}
      </DataHandleRanges>

      <StorageHints>
      TroveSyncMeta ${lib.boolToYesNo fs.troveSyncMeta}
      TroveSyncData ${lib.boolToYesNo fs.troveSyncData}
      ${fs.extraStorageHints}
      </StorageHints>

    </FileSystem>
  '') cfg.fileSystems;

  configFile = ''
    <Defaults>
    LogType ${cfg.logType}
    DataStorageSpace ${cfg.dataStorageSpace}
    MetaDataStorageSpace ${cfg.metadataStorageSpace}

    BMIModules ${lib.concatStringsSep "," cfg.BMIModules}
    ${cfg.extraDefaults}
    </Defaults>

    ${cfg.extraConfig}

    <Aliases>
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (alias: url: "Alias ${alias} ${url}") cfg.servers)}
    </Aliases>

    ${lib.concatStringsSep "\n" fileSystems}
  '';

in
{
  ###### interface

  options = {
    services.orangefs.server = {
      enable = lib.mkEnableOption "OrangeFS server";

      BMIModules = lib.mkOption {
        default = [ "bmi_tcp" ];
        description = "List of BMI modules to load.";

        example = [
          "bmi_tcp"
          "bmi_ib"
        ];

        type = with lib.types; listOf str;
      };

      dataStorageSpace = lib.mkOption {
        default = null;
        description = "Directory for data storage.";
        example = "/data/storage";
        type = lib.types.nullOr lib.types.str;
      };

      extraConfig = lib.mkOption {
        default = "";
        description = "Extra config for the global section.";
        type = lib.types.lines;
      };

      extraDefaults = lib.mkOption {
        default = "";
        description = "Extra config for `<Defaults>` section.";
        type = lib.types.lines;
      };

      fileSystems = lib.mkOption {
        default = {
          orangefs = { };
        };

        description = ''
          These options will create the `<FileSystem>` sections of config file.
        '';

        example = lib.literalExpression ''
          {
            fs1 = {
              id = 101;
            };

            fs2 = {
              id = 102;
            };
          }
        '';

        type =
          with lib.types;
          attrsOf (
            submodule (
              { ... }:
              {
                options = {
                  extraConfig = lib.mkOption {
                    default = "";
                    description = "Extra config for `<FileSystem>` section.";
                    type = lib.types.lines;
                  };

                  extraStorageHints = lib.mkOption {
                    default = "";
                    description = "Extra config for `<StorageHints>` section.";
                    type = lib.types.lines;
                  };

                  id = lib.mkOption {
                    default = 1;
                    description = "File system ID (must be unique within configuration).";
                    type = lib.types.int;
                  };

                  rootHandle = lib.mkOption {
                    default = 3;
                    description = "File system root ID.";
                    type = lib.types.int;
                  };

                  troveSyncData = lib.mkOption {
                    default = false;
                    description = "Sync data.";
                    type = lib.types.bool;
                  };

                  troveSyncMeta = lib.mkOption {
                    default = true;
                    description = "Sync meta data.";
                    type = lib.types.bool;
                  };
                };
              }
            )
          );
      };

      logType = lib.mkOption {
        default = "syslog";
        description = "Destination for log messages.";

        type =
          with lib.types;
          enum [
            "file"
            "syslog"
          ];
      };

      metadataStorageSpace = lib.mkOption {
        default = null;
        description = "Directory for meta data storage.";
        example = "/data/meta";
        type = lib.types.nullOr lib.types.str;
      };

      servers = lib.mkOption {
        default = { };
        description = "URLs for storage server including port. The attribute names define the server alias.";

        example = {
          node1 = "tcp://node1:3334";
          node2 = "tcp://node2:3334";
        };

        type = with lib.types; attrsOf lib.types.str;
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    # To format the file system the config file is needed.
    environment.etc."orangefs/server.conf" = {
      group = "orangefs";
      text = configFile;
      user = "orangefs";
    };

    environment.systemPackages = [ pkgs.orangefs ];

    systemd.services.orangefs-server = {
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];

      serviceConfig = {
        # Run as "simple" in foreground mode.
        # This is more reliable
        ExecStart = ''
          ${pkgs.orangefs}/bin/pvfs2-server -d \
            /etc/orangefs/server.conf
        '';

        Group = "orangefs";
        TimeoutStopSec = "120";
        User = "orangefs";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.orangefs = { };

    # orangefs daemon will run as user
    users.users.orangefs = {
      group = "orangefs";
      isSystemUser = true;
    };
  };

}
