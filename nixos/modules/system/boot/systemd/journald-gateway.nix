{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.journald.gateway;

  cliArgs = lib.cli.toCommandLineShellGNU { } {
    # If either of these are false, they are not passed in the command-line
    inherit (cfg)
      system
      user
      merge
      ;
  };

  tlsOptionRemovedMessage = ''
    systemd in Nixpkgs is built without GnuTLS, so systemd-journal-gatewayd
    cannot serve HTTPS. Use a reverse proxy (such as nginx) to terminate TLS
    in front of the gateway if you need encrypted access.
  '';
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "journald" "enableHttpGateway" ]
      [ "services" "journald" "gateway" "enable" ]
    )
    (lib.mkRemovedOptionModule [ "services" "journald" "gateway" "cert" ] tlsOptionRemovedMessage)
    (lib.mkRemovedOptionModule [ "services" "journald" "gateway" "key" ] tlsOptionRemovedMessage)
    (lib.mkRemovedOptionModule [ "services" "journald" "gateway" "trust" ] tlsOptionRemovedMessage)
  ];

  options.services.journald.gateway = {
    enable = lib.mkEnableOption "the HTTP gateway to the journal";

    merge = lib.mkOption {
      default = false;

      description = ''
        Serve entries interleaved from all available journals, including other
        machines.

        This has the same meaning as `--merge` option for
        {manpage}`journalctl(1)`.
      '';

      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 19531;

      description = ''
        The port to listen to.
      '';

      type = lib.types.port;
    };

    system = lib.mkOption {
      default = false;

      description = ''
        Serve entries from system services and the kernel.

        This has the same meaning as `--system` for {manpage}`journalctl(1)`.
      '';

      type = lib.types.bool;
    };

    user = lib.mkOption {
      default = false;

      description = ''
        Serve entries from services for the current user.

        This has the same meaning as `--user` for {manpage}`journalctl(1)`.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.additionalUpstreamSystemUnits = [
      "systemd-journal-gatewayd.socket"
      "systemd-journal-gatewayd.service"
    ];

    systemd.services.systemd-journal-gatewayd.serviceConfig.ExecStart = [
      # Clear the default command line
      ""
      "${pkgs.systemd}/lib/systemd/systemd-journal-gatewayd ${cliArgs}"
    ];

    systemd.sockets.systemd-journal-gatewayd = {
      listenStreams = [
        # Clear the default port
        ""
        (toString cfg.port)
      ];

      wantedBy = [ "sockets.target" ];
    };

    users.groups.systemd-journal-gateway.gid = config.ids.gids.systemd-journal-gateway;
    users.users.systemd-journal-gateway.group = "systemd-journal-gateway";
    users.users.systemd-journal-gateway.uid = config.ids.uids.systemd-journal-gateway;
  };

  meta.maintainers = [ ];
}
