{
  config,
  lib,
  name,
  ...
}:
{
  options = {
    dataPath = lib.mkOption {
      default = "/var/lib/pantalaimon-${name}";

      description = ''
        The directory where `pantalaimon` should store its state such as the database file.
      '';

      type = lib.types.path;
    };

    extraSettings = lib.mkOption {
      default = { };

      description = ''
        Extra configuration options. See
        [pantalaimon(5)](https://github.com/matrix-org/pantalaimon/blob/master/docs/man/pantalaimon.5.md)
        for available options.
      '';

      type = lib.types.attrs;
    };

    homeserver = lib.mkOption {
      description = ''
        The URI of the homeserver that the `pantalaimon` proxy should
        forward requests to, without the matrix API path but including
        the http(s) schema.
      '';

      example = "https://matrix.org";
      type = lib.types.str;
    };

    listenAddress = lib.mkOption {
      default = "localhost";

      description = ''
        The address where the daemon will listen to client connections
        for this homeserver.
      '';

      type = lib.types.str;
    };

    listenPort = lib.mkOption {
      default = 8009;

      description = ''
        The port where the daemon will listen to client connections for
        this homeserver. Note that the listen address/port combination
        needs to be lib.unique between different homeservers.
      '';

      type = lib.types.port;
    };

    logLevel = lib.mkOption {
      default = "warning";

      description = ''
        Set the log level of the daemon.
      '';

      type = lib.types.enum [
        "info"
        "warning"
        "error"
        "debug"
      ];
    };

    ssl = lib.mkOption {
      default = true;

      description = ''
        Whether or not SSL verification should be enabled for outgoing
        connections to the homeserver.
      '';

      type = lib.types.bool;
    };
  };
}
