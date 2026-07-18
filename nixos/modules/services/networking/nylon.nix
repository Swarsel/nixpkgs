{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.nylon;

  homeDir = "/var/lib/nylon";

  configFile =
    cfg:
    pkgs.writeText "nylon-${cfg.name}.conf" ''
      [General]
      No-Simultaneous-Conn=${toString cfg.nrConnections}
      Log=${if cfg.logging then "1" else "0"}
      Verbose=${if cfg.verbosity then "1" else "0"}

      [Server]
      Binding-Interface=${cfg.acceptInterface}
      Connecting-Interface=${cfg.bindInterface}
      Port=${toString cfg.port}
      Allow-IP=${lib.concatStringsSep " " cfg.allowedIPRanges}
      Deny-IP=${lib.concatStringsSep " " cfg.deniedIPRanges}
    '';

  nylonOpts =
    { name, ... }:
    {

      options = {

        enable = lib.mkOption {
          default = false;

          description = ''
            Enables nylon as a running service upon activation.
          '';

          type = lib.types.bool;
        };

        acceptInterface = lib.mkOption {
          default = "lo";

          description = ''
            Tell nylon which interface to listen for client requests on, default is "lo".
          '';

          type = lib.types.str;
        };

        allowedIPRanges = lib.mkOption {
          default = [
            "192.168.0.0/16"
            "127.0.0.1/8"
            "172.16.0.1/12"
            "10.0.0.0/8"
          ];

          description = ''
            Allowed client IP ranges are evaluated first, defaults to ARIN IPv4 private ranges:
              [ "192.168.0.0/16" "127.0.0.0/8" "172.16.0.0/12" "10.0.0.0/8" ]
          '';

          type = with lib.types; listOf str;
        };

        bindInterface = lib.mkOption {
          default = "enp3s0f0";

          description = ''
            Tell nylon which interface to use as an uplink, default is "enp3s0f0".
          '';

          type = lib.types.str;
        };

        deniedIPRanges = lib.mkOption {
          default = [ "0.0.0.0/0" ];

          description = ''
            Denied client IP ranges, these gets evaluated after the allowed IP ranges, defaults to all IPv4 addresses:
              [ "0.0.0.0/0" ]
            To block all other access than the allowed.
          '';

          type = with lib.types; listOf str;
        };

        logging = lib.mkOption {
          default = false;

          description = ''
            Enable logging, default is no logging.
          '';

          type = lib.types.bool;
        };

        name = lib.mkOption {
          default = "";
          description = "The name of this nylon instance.";
          type = lib.types.str;
        };

        nrConnections = lib.mkOption {
          default = 10;

          description = ''
            The number of allowed simultaneous connections to the daemon, default 10.
          '';

          type = lib.types.int;
        };

        port = lib.mkOption {
          default = 1080;

          description = ''
            What port to listen for client requests, default is 1080.
          '';

          type = lib.types.port;
        };

        verbosity = lib.mkOption {
          default = false;

          description = ''
            Enable verbose output, default is to not be verbose.
          '';

          type = lib.types.bool;
        };
      };

      config = {
        name = lib.mkDefault name;
      };
    };

  mkNamedNylon = cfg: {
    "nylon-${cfg.name}" = {
      after = [ "network.target" ];
      description = "Nylon, a lightweight SOCKS proxy server";

      serviceConfig = {
        ExecStart = "${pkgs.nylon}/bin/nylon -f -c ${configFile cfg}";
        Group = "nylon";
        User = "nylon";
        WorkingDirectory = homeDir;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  anyNylons = lib.collect (p: p ? enable) cfg;
  enabledNylons = lib.filter (p: p.enable == true) anyNylons;
  nylonUnits = map (nylon: mkNamedNylon nylon) enabledNylons;

in

{

  ###### interface

  options = {

    services.nylon = lib.mkOption {
      default = { };
      description = "Collection of named nylon instances";
      internal = true;
      type = with lib.types; attrsOf (submodule nylonOpts);
    };

  };

  ###### implementation

  config = lib.mkIf (lib.length enabledNylons > 0) {

    systemd.services = lib.foldr (a: b: a // b) { } nylonUnits;
    users.groups.nylon.gid = config.ids.gids.nylon;

    users.users.nylon = {
      createHome = true;
      description = "Nylon SOCKS Proxy";
      group = "nylon";
      home = homeDir;
      uid = config.ids.uids.nylon;
    };

  };
}
