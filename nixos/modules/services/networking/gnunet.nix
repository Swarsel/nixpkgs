{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.gnunet;

  stateDir = "/var/lib/gnunet";

  configFile = with cfg; ''
    [PATHS]
    GNUNET_HOME = ${stateDir}
    GNUNET_RUNTIME_DIR = /run/gnunet
    GNUNET_USER_RUNTIME_DIR = /run/gnunet
    GNUNET_DATA_HOME = ${stateDir}/data

    [ats]
    WAN_QUOTA_IN = ${toString load.maxNetDownBandwidth} b
    WAN_QUOTA_OUT = ${toString load.maxNetUpBandwidth} b

    [datastore]
    QUOTA = ${toString fileSharing.quota} MB

    [transport-udp]
    PORT = ${toString udp.port}
    ADVERTISED_PORT = ${toString udp.port}

    [transport-tcp]
    PORT = ${toString tcp.port}
    ADVERTISED_PORT = ${toString tcp.port}

    ${extraOptions}
  '';

in

{

  ###### interface

  options = {

    services.gnunet = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to run the GNUnet daemon.  GNUnet is GNU's anonymous
          peer-to-peer communication and file sharing framework.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "gnunet" {
        example = "gnunet_git";
      };

      extraOptions = lib.mkOption {
        default = "";

        description = ''
          Additional options that will be copied verbatim in {file}`gnunet.conf`.
          See {manpage}`gnunet.conf(5)` for details.
        '';

        type = lib.types.lines;
      };

      fileSharing = {
        quota = lib.mkOption {
          default = 1024;

          description = ''
            Maximum file system usage (in MiB) for file sharing.
          '';

          type = lib.types.int;
        };
      };

      load = {
        hardNetUpBandwidth = lib.mkOption {
          default = 0;

          description = ''
            Hard bandwidth limit (in bits per second) when uploading
            data.
          '';

          type = lib.types.int;
        };

        maxNetDownBandwidth = lib.mkOption {
          default = 50000;

          description = ''
            Maximum bandwidth usage (in bits per second) for GNUnet
            when downloading data.
          '';

          type = lib.types.int;
        };

        maxNetUpBandwidth = lib.mkOption {
          default = 50000;

          description = ''
            Maximum bandwidth usage (in bits per second) for GNUnet
            when downloading data.
          '';

          type = lib.types.int;
        };
      };

      tcp = {
        port = lib.mkOption {
          default = 2086; # assigned by IANA

          description = ''
            The TCP port for use by GNUnet.
          '';

          type = lib.types.port;
        };
      };

      udp = {
        port = lib.mkOption {
          default = 2086; # assigned by IANA

          description = ''
            The UDP port for use by GNUnet.
          '';

          type = lib.types.port;
        };
      };
    };

  };

  ###### implementation

  config = lib.mkIf config.services.gnunet.enable {

    environment.etc."gnunet.conf".text = configFile;
    # The user tools that talk to `gnunetd' should come from the same source,
    # so install them globally.
    environment.systemPackages = [ cfg.package ];

    systemd.services.gnunet = {
      after = [ "network.target" ];
      description = "GNUnet";
      documentation = [ "info:gnunet" ];

      path = [
        cfg.package
        pkgs.miniupnpc
      ];

      restartTriggers = [ config.environment.etc."gnunet.conf".source ];
      serviceConfig.ExecStart = "${cfg.package}/lib/gnunet/libexec/gnunet-service-arm -c /etc/gnunet.conf";
      serviceConfig.RuntimeDirectory = "gnunet";
      serviceConfig.StateDirectory = "gnunet";
      serviceConfig.UMask = "0007";
      serviceConfig.User = "gnunet";
      serviceConfig.WorkingDirectory = stateDir;
      wantedBy = [ "multi-user.target" ];
    };

    users.groups.gnunet.gid = config.ids.gids.gnunet;

    users.users.gnunet = {
      description = "GNUnet User";
      group = "gnunet";
      uid = config.ids.uids.gnunet;
    };

  };

}
