{ lib, ... }:
{
  options.services.nghttpx = {
    enable = lib.mkEnableOption "nghttpx";

    backend-address-family = lib.mkOption {
      default = "auto";

      description = ''
        Specify address family of backend connections. If "auto" is
        given, both IPv4 and IPv6 are considered. If "IPv4" is given,
        only IPv4 address is considered. If "IPv6" is given, only IPv6
        address is considered.

        Please see <https://nghttp2.org/documentation/nghttpx.1.html#cmdoption-nghttpx--backend-address-family>
      '';

      type = lib.types.enum [
        "auto"
        "IPv4"
        "IPv6"
      ];
    };

    backends = lib.mkOption {
      description = ''
        A list of backend specifications.
      '';

      example = [
        {
          params = {
            proto = "http/1.1";
            redirect-if-not-tls = true;
          };

          patterns = [ "/" ];

          server = {
            host = "172.16.0.22";
            port = 8443;
          };
        }
      ];

      type = lib.types.listOf (lib.types.submodule (import ./backend-submodule.nix));
    };

    backlog = lib.mkOption {
      default = 65536;

      description = ''
        Listen backlog size.

        Please see <https://nghttp2.org/documentation/nghttpx.1.html#cmdoption-nghttpx--backlog>
      '';

      type = lib.types.int;
    };

    extraConfig = lib.mkOption {
      default = "";

      description = ''
        Extra configuration options to be appended to the generated
        configuration file.
      '';

      type = lib.types.lines;
    };

    frontends = lib.mkOption {
      description = ''
        A list of frontend listener specifications.
      '';

      example = [
        {
          params = {
            tls = "no-tls";
          };

          server = {
            host = "*";
            port = 80;
          };
        }
      ];

      type = lib.types.listOf (lib.types.submodule (import ./frontend-submodule.nix));
    };

    rlimit-nofile = lib.mkOption {
      default = 0;

      description = ''
        Set maximum number of open files (RLIMIT_NOFILE) to \<N\>. If 0
        is given, nghttpx does not set the limit.

        Please see <https://nghttp2.org/documentation/nghttpx.1.html#cmdoption-nghttpx--rlimit-nofile>
      '';

      type = lib.types.int;
    };

    single-process = lib.mkOption {
      default = false;

      description = ''
        Run this program in a single process mode for debugging
        purpose. Without this option, nghttpx creates at least 2
        processes: master and worker processes. If this option is
        used, master and worker are unified into a single
        process. nghttpx still spawns additional process if neverbleed
        is used. In the single process mode, the signal handling
        feature is disabled.

        Please see <https://nghttp2.org/documentation/nghttpx.1.html#cmdoption-nghttpx--single-process>
      '';

      type = lib.types.bool;
    };

    single-thread = lib.mkOption {
      default = false;

      description = ''
        Run everything in one thread inside the worker process. This
        feature is provided for better debugging experience, or for
        the platforms which lack thread support. If threading is
        disabled, this option is always enabled.

        Please see <https://nghttp2.org/documentation/nghttpx.1.html#cmdoption-nghttpx--single-thread>
      '';

      type = lib.types.bool;
    };

    tls = lib.mkOption {
      default = null;

      description = ''
        TLS certificate and key paths. Note that this does not enable
        TLS for a frontend listener, to do so, a frontend
        specification must set `params.tls` to true.
      '';

      example = {
        crt = "/etc/ssl/certs/server.crt";
        key = "/etc/ssl/keys/server.key";
      };

      type = lib.types.nullOr (lib.types.submodule (import ./tls-submodule.nix));
    };

    workers = lib.mkOption {
      default = 1;

      description = ''
        Set the number of worker threads.

        Please see <https://nghttp2.org/documentation/nghttpx.1.html#cmdoption-nghttpx-n>
      '';

      type = lib.types.int;
    };
  };
}
