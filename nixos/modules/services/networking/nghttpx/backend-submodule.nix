{ lib, ... }:
{
  options = {
    params = lib.mkOption {
      default = null;

      description = ''
        Parameters to configure a backend.
      '';

      example = {
        proto = "h2";
        tls = true;
      };

      type = lib.types.nullOr (lib.types.submodule (import ./backend-params-submodule.nix));
    };

    patterns = lib.mkOption {
      default = [ ];

      description = ''
        List of nghttpx backend patterns.

        Please see <https://nghttp2.org/documentation/nghttpx.1.html#cmdoption-nghttpx-b>
        for more information on the pattern syntax and nghttpxs behavior.
      '';

      example = [
        "*.host.net/v1/"
        "host.org/v2/mypath"
        "/somepath"
      ];

      type = lib.types.listOf lib.types.str;
    };

    server = lib.mkOption {
      default = {
        host = "127.0.0.1";
        port = 80;
      };

      description = ''
        Backend server location specified as either a host:port pair
        or a unix domain docket.
      '';

      example = {
        host = "127.0.0.1";
        port = 8888;
      };

      type = lib.types.either (lib.types.submodule (import ./server-options.nix)) (lib.types.path);
    };
  };
}
