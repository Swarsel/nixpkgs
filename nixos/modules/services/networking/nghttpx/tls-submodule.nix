{ lib, ... }:
{
  options = {
    crt = lib.mkOption {
      default = "/etc/ssl/certs/server.crt";

      description = ''
        Path to the TLS certificate file.
      '';

      example = "/etc/ssl/certs/mycert.crt";
      type = lib.types.str;
    };

    key = lib.mkOption {
      default = "/etc/ssl/keys/server.key";

      description = ''
        Path to the TLS key file.
      '';

      example = "/etc/ssl/keys/mykeyfile.key";
      type = lib.types.str;
    };
  };
}
