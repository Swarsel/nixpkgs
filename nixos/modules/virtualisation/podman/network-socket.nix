{
  config,
  lib,
  pkg,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;

  cfg = config.virtualisation.podman.networkSocket;

in
{
  imports = [
    ./network-socket-ghostunnel.nix
  ];

  options.virtualisation.podman.networkSocket = {
    enable = mkOption {
      default = false;

      description = ''
        Make the Podman and Docker compatibility API available over the network
        with TLS client certificate authentication.

        This allows Docker clients to connect with the equivalents of the Docker
        CLI `-H` and `--tls*` family of options.

        For certificate setup, see <https://docs.docker.com/engine/security/protect-access/>

        This option is independent of [](#opt-virtualisation.podman.dockerSocket.enable).
      '';

      type = types.bool;
    };

    listenAddress = mkOption {
      default = "0.0.0.0";

      description = ''
        Interface address for receiving TLS connections.
      '';

      type = types.str;
    };

    openFirewall = mkOption {
      default = false;

      description = ''
        Whether to open the port in the firewall.
      '';

      type = types.bool;
    };

    port = mkOption {
      default = 2376;

      description = ''
        TCP port number for receiving TLS connections.
      '';

      type = types.port;
    };

    server = mkOption {
      description = ''
        Choice of TLS proxy server.
      '';

      example = "ghostunnel";
      type = types.enum [ ];
    };

    tls.cacert = mkOption {
      description = ''
        Path to CA certificate to use for client authentication.
      '';

      type = types.path;
    };

    tls.cert = mkOption {
      description = ''
        Path to certificate describing the server.
      '';

      type = types.path;
    };

    tls.key = mkOption {
      description = ''
        Path to the private key corresponding to the server certificate.

        Use a string for this setting. Otherwise it will be copied to the Nix
        store first, where it is readable by any system process.
      '';

      type = types.path;
    };
  };

  config = {
    networking.firewall.allowedTCPPorts = lib.optional (cfg.enable && cfg.openFirewall) cfg.port;
  };

  meta.maintainers = [ lib.maintainers.roberth ];
  meta.teams = [ lib.teams.podman ];
}
