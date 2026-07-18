{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.types) listOf oneOf str;

  cfg = config.services.epmd;
in
{
  ###### interface
  options.services.epmd = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable socket activation for Erlang Port Mapper Daemon (epmd),
        which acts as a name server on all hosts involved in distributed
        Erlang computations.
      '';

      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs [ "beamPackages" "erlang" ] { };

    listenStream = lib.mkOption {
      default = "[::]:4369";

      description = ''
        the listenStream used by the systemd socket.
        see <https://www.freedesktop.org/software/systemd/man/systemd.socket.html#ListenStream=> for more information.
        use this to change the port epmd will run on.
        if not defined, epmd will use "[::]:4369"
      '';

      type = oneOf [
        str
        (listOf str)
      ];
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.listenStream == "[::]:4369" -> config.networking.enableIPv6;
        message = "epmd listens by default on ipv6, enable ipv6 or change config.services.epmd.listenStream";
      }
    ];

    systemd.services.epmd = {
      after = [ "network.target" ];
      description = "Erlang Port Mapper Daemon";
      requires = [ "epmd.socket" ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/epmd -systemd";
        Type = "notify";
      };
    };

    systemd.sockets.epmd = rec {
      before = wantedBy;
      description = "Erlang Port Mapper Daemon Activation Socket";

      socketConfig = {
        Accept = "false";
        ListenStream = cfg.listenStream;
      };

      wantedBy = [ "sockets.target" ];
    };
  };

  meta.teams = [ lib.teams.beam ];
}
