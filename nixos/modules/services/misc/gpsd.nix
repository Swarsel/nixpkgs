{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let

  uid = config.ids.uids.gpsd;
  gid = config.ids.gids.gpsd;
  cfg = config.services.gpsd;

in
{

  ###### interface

  imports = [
    (lib.mkRemovedOptionModule [ "services" "gpsd" "device" ] "Use `services.gpsd.devices` instead.")
  ];

  options = {

    services.gpsd = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable `gpsd`, a GPS service daemon.
        '';

        type = lib.types.bool;
      };

      debugLevel = lib.mkOption {
        default = 0;

        description = ''
          The debugging level.
        '';

        type = lib.types.int;
      };

      devices = lib.mkOption {
        default = [ "/dev/ttyUSB0" ];

        description = ''
          List of devices that `gpsd` should subscribe to.

          A device may be a local serial device for GPS input, or a
          URL of the form:
          `[{dgpsip|ntrip}://][user:passwd@]host[:port][/stream]` in
          which case it specifies an input source for DGPS or ntrip
          data.
        '';

        type = lib.types.listOf lib.types.str;
      };

      extraArgs = lib.mkOption {
        default = [ ];

        description = ''
          A list of extra command line arguments to pass to gpsd.
          Check {manpage}`gpsd(8)` mangpage for possible arguments.
        '';

        example = [
          "-r"
          "-s"
          "19200"
        ];

        type = lib.types.listOf lib.types.str;
      };

      listenany = lib.mkOption {
        default = false;

        description = ''
          Listen on all addresses rather than just loopback.
        '';

        type = lib.types.bool;
      };

      nowait = lib.mkOption {
        default = false;

        description = ''
          don't wait for client connects to poll GPS
        '';

        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 2947;

        description = ''
          The port where to listen for TCP connections.
        '';

        type = lib.types.port;
      };

      readonly = lib.mkOption {
        default = true;

        description = ''
          Whether to enable the broken-device-safety, otherwise
          known as read-only mode.  Some popular bluetooth and USB
          receivers lock up or become totally inaccessible when
          probed or reconfigured.  This switch prevents gpsd from
          writing to a receiver.  This means that gpsd cannot
          configure the receiver for optimal performance, but it
          also means that gpsd cannot break the receiver.  A better
          solution would be for Bluetooth to not be so fragile.  A
          platform independent method to identify
          serial-over-Bluetooth devices would also be nice.
        '';

        type = lib.types.bool;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    systemd.services.gpsd = {
      after = [ "network.target" ];
      description = "GPSD daemon";

      serviceConfig = {
        ExecStart =
          let
            devices = utils.escapeSystemdExecArgs cfg.devices;
            extraArgs = utils.escapeSystemdExecArgs cfg.extraArgs;
          in
          ''
            ${pkgs.gpsd}/sbin/gpsd -D "${toString cfg.debugLevel}"  \
              -S "${toString cfg.port}"                             \
              ${lib.optionalString cfg.readonly "-b"}                   \
              ${lib.optionalString cfg.nowait "-n"}                     \
              ${lib.optionalString cfg.listenany "-G"}                  \
              ${extraArgs}                                          \
              ${devices}
          '';

        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.gpsd = { inherit gid; };

    users.users.gpsd = {
      inherit uid;
      description = "gpsd daemon user";
      group = "gpsd";
      home = "/var/empty";
    };

  };

}
