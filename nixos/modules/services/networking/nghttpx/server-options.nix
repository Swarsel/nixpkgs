{ lib, ... }:
{
  options = {
    host = lib.mkOption {
      description = ''
        Server host address.
      '';

      example = "127.0.0.1";
      type = lib.types.str;
    };

    port = lib.mkOption {
      description = ''
        Server host port.
      '';

      example = 5088;
      type = lib.types.port;
    };
  };
}
