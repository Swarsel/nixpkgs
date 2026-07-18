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
  options.virtualisation.podman.networkSocket = {
    server = mkOption {
      type = types.enum [ "ghostunnel" ];
    };
  };

  config = lib.mkIf (cfg.enable && cfg.server == "ghostunnel") {

    services.ghostunnel = {
      enable = true;

      servers."podman-socket" = {
        inherit (cfg.tls) cert key cacert;
        allowAll = lib.mkDefault true;
        listen = "${cfg.listenAddress}:${toString cfg.port}";
        target = "unix:/run/podman/podman.sock";
      };
    };

    systemd.services.ghostunnel-server-podman-socket.serviceConfig.SupplementaryGroups = [ "podman" ];

  };

  meta.maintainers = [ lib.maintainers.roberth ];
  meta.teams = [ lib.teams.podman ];
}
