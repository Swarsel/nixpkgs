{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.autossh;

in

{

  ###### interface

  options = {

    services.autossh = {

      sessions = lib.mkOption {
        default = [ ];

        description = ''
          List of AutoSSH sessions to start as systemd services. Each service is
          named 'autossh-{session.name}'.
        '';

        example = [
          {
            extraArguments = "-N -D4343 billremote@socks.host.net";
            monitoringPort = 20000;
            name = "socks-peer";
            user = "bill";
          }
        ];

        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              extraArguments = lib.mkOption {
                description = ''
                  Arguments to be passed to AutoSSH and retransmitted to SSH
                  process. Some meaningful options include -N (don't run remote
                  command), -D (open SOCKS proxy on local port), -R (forward
                  remote port), -L (forward local port), -v (Enable debug). Check
                  ssh manual for the complete list.
                '';

                example = "-N -D4343 bill@socks.example.net";
                type = lib.types.separatedString " ";
              };

              monitoringPort = lib.mkOption {
                default = 0;

                description = ''
                  Port to be used by AutoSSH for peer monitoring. Note, that
                  AutoSSH also uses mport+1. Value of 0 disables the keep-alive
                  style monitoring
                '';

                example = 20000;
                type = lib.types.port;
              };

              name = lib.mkOption {
                description = "Name of the local AutoSSH session";
                example = "socks-peer";
                type = lib.types.str;
              };

              user = lib.mkOption {
                description = "Name of the user the AutoSSH session should run as";
                example = "bill";
                type = lib.types.str;
              };
            };
          }
        );

      };
    };

  };

  ###### implementation

  config = lib.mkIf (cfg.sessions != [ ]) {

    environment.systemPackages = [ pkgs.autossh ];

    systemd.services =

      lib.foldr (
        s: acc:
        acc
        // {
          "autossh-${s.name}" =
            let
              mport = if s ? monitoringPort then s.monitoringPort else 0;
            in
            {
              after = [ "network.target" ];
              description = "AutoSSH session (" + s.name + ")";
              # To be able to start the service with no network connection
              environment.AUTOSSH_GATETIME = "0";
              # How often AutoSSH checks the network, in seconds
              environment.AUTOSSH_POLL = "30";

              serviceConfig = {
                ExecStart = "${pkgs.autossh}/bin/autossh -M ${toString mport} ${s.extraArguments}";
                # AutoSSH may exit with 0 code if the SSH session was
                # gracefully terminated by either local or remote side.
                Restart = "on-success";
                User = "${s.user}";
              };

              wantedBy = [ "multi-user.target" ];
            };
        }
      ) { } cfg.sessions;

  };
}
