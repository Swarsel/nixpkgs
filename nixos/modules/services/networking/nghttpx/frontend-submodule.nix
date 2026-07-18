{ lib, ... }:
{
  options = {
    params = lib.mkOption {
      default = null;

      description = ''
        Parameters to configure a backend.
      '';

      example = {
        tls = "tls";
      };

      type = lib.types.nullOr (lib.types.submodule (import ./frontend-params-submodule.nix));
    };

    server = lib.mkOption {
      default = {
        host = "127.0.0.1";
        port = 80;
      };

      description = ''
        Frontend server interface binding specification as either a
        host:port pair or a unix domain docket.

        NB: a host of "*" listens on all interfaces and includes IPv6
        addresses.
      '';

      example = {
        host = "127.0.0.1";
        port = 8888;
      };

      type = lib.types.either (lib.types.submodule (import ./server-options.nix)) (lib.types.path);
    };
  };
}
