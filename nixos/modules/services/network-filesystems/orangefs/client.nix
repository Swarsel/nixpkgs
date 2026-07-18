{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.orangefs.client;

in
{
  ###### interface

  options = {
    services.orangefs.client = {
      enable = lib.mkEnableOption "OrangeFS client daemon";

      extraOptions = lib.mkOption {
        default = [ ];
        description = "Extra command line options for pvfs2-client.";
        type = with lib.types; listOf str;
      };

      fileSystems = lib.mkOption {
        description = ''
          The orangefs file systems to be mounted.
          This option is preferred over using {option}`fileSystems` directly since
          the pvfs client service needs to be running for it to be mounted.
        '';

        example = [
          {
            mountPoint = "/orangefs";
            target = "tcp://server:3334/orangefs";
          }
        ];

        type =
          with lib.types;
          listOf (
            submodule (
              { ... }:
              {
                options = {

                  options = lib.mkOption {
                    default = [ ];
                    description = "Mount options";
                    type = with lib.types; listOf str;
                  };

                  mountPoint = lib.mkOption {
                    default = "/orangefs";
                    description = "Mount point.";
                    type = lib.types.str;
                  };

                  target = lib.mkOption {
                    description = "Target URL";
                    example = "tcp://server:3334/orangefs";
                    type = lib.types.str;
                  };
                };
              }
            )
          );
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "orangefs" ];
    boot.supportedFilesystems = [ "pvfs2" ];
    environment.systemPackages = [ pkgs.orangefs ];

    systemd.mounts = map (fs: {
      options = lib.concatStringsSep "," fs.options;
      after = [ "orangefs-client.service" ];
      bindsTo = [ "orangefs-client.service" ];
      requires = [ "orangefs-client.service" ];
      type = "pvfs2";
      wantedBy = [ "remote-fs.target" ];
      what = fs.target;
      where = fs.mountPoint;
    }) cfg.fileSystems;

    systemd.services.orangefs-client = {
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.orangefs}/bin/pvfs2-client-core \
             --logtype=syslog ${lib.concatStringsSep " " cfg.extraOptions}
        '';

        TimeoutStopSec = "120";
        Type = "simple";
      };
    };
  };
}
