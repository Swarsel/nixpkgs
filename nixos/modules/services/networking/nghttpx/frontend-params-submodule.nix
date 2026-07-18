{ lib, ... }:
{
  options = {
    api = lib.mkOption {
      default = false;

      description = ''
        Enable API access for this frontend. This enables you to
        dynamically modify nghttpx at run-time therefore this feature
        is disabled by default and should be turned on with care.

        Please see <https://nghttp2.org/documentation/nghttpx.1.html#cmdoption-nghttpx-f>
        for more detail.
      '';

      type = lib.types.bool;
    };

    healthmon = lib.mkOption {
      default = false;

      description = ''
        Make this frontend a health monitor endpoint. Any request
        received on this frontend is responded to with a 200 OK.

        Please see <https://nghttp2.org/documentation/nghttpx.1.html#cmdoption-nghttpx-f>
        for more detail.
      '';

      type = lib.types.bool;
    };

    proxyproto = lib.mkOption {
      default = false;

      description = ''
        Accept PROXY protocol version 1 on frontend connection.

        Please see <https://nghttp2.org/documentation/nghttpx.1.html#cmdoption-nghttpx-f>
        for more detail.
      '';

      type = lib.types.bool;
    };

    sni-fwd = lib.mkOption {
      default = false;

      description = ''
        When performing a match to select a backend server, SNI host
        name received from the client is used instead of the request
        host. See --backend option about the pattern match.

        Please see <https://nghttp2.org/documentation/nghttpx.1.html#cmdoption-nghttpx-f>
        for more detail.
      '';

      type = lib.types.bool;
    };

    tls = lib.mkOption {
      default = "tls";

      description = ''
        Enable or disable TLS. If true (enabled) the key and
        certificate must be configured for nghttpx.

        Please see <https://nghttp2.org/documentation/nghttpx.1.html#cmdoption-nghttpx-f>
        for more detail.
      '';

      type = lib.types.enum [
        "tls"
        "no-tls"
      ];
    };
  };
}
