{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.xinetd;

  configFile = pkgs.writeText "xinetd.conf" ''
    defaults
    {
      log_type       = SYSLOG daemon info
      log_on_failure = HOST
      log_on_success = PID HOST DURATION EXIT
      ${cfg.extraDefaults}
    }

    ${concatMapStrings makeService cfg.services}
  '';

  makeService = srv: ''
    service ${srv.name}
    {
      protocol    = ${srv.protocol}
      ${optionalString srv.unlisted "type        = UNLISTED"}
      ${optionalString (srv.flags != "") "flags = ${srv.flags}"}
      socket_type = ${if srv.protocol == "udp" then "dgram" else "stream"}
      ${optionalString (srv.port != 0) "port        = ${toString srv.port}"}
      wait        = ${lib.boolToYesNo (srv.protocol == "udp")}
      user        = ${srv.user}
      server      = ${srv.server}
      ${optionalString (srv.serverArgs != "") "server_args = ${srv.serverArgs}"}
      ${srv.extraConfig}
    }
  '';

in

{

  ###### interface

  options = {

    services.xinetd.enable = mkEnableOption "the xinetd super-server daemon";

    services.xinetd.extraDefaults = mkOption {
      default = "";

      description = ''
        Additional configuration lines added to the default section of xinetd's configuration.
      '';

      type = types.lines;
    };

    services.xinetd.services = mkOption {
      default = [ ];

      description = ''
        A list of services provided by xinetd.
      '';

      type =
        with types;
        listOf (submodule {

          options = {

            extraConfig = mkOption {
              default = "";
              description = "Extra configuration-lines added to the section of the service.";
              type = types.lines;
            };

            flags = mkOption {
              default = "";
              description = "";
              type = types.str;
            };

            name = mkOption {
              description = "Name of the service.";
              example = "login";
              type = types.str;
            };

            port = mkOption {
              default = 0;
              description = "Port number of the service.";
              example = 123;
              type = types.port;
            };

            protocol = mkOption {
              default = "tcp";
              description = "Protocol of the service.  Usually `tcp` or `udp`.";
              type = types.str;
            };

            server = mkOption {
              description = "Path of the program that implements the service.";
              example = "/foo/bin/ftpd";
              type = types.str;
            };

            serverArgs = mkOption {
              default = "";
              description = "Command-line arguments for the server program.";
              type = types.separatedString " ";
            };

            unlisted = mkOption {
              default = false;

              description = ''
                Whether this server is listed in
                {file}`/etc/services`.  If so, the port
                number can be omitted.
              '';

              type = types.bool;
            };

            user = mkOption {
              default = "nobody";
              description = "User account for the service";
              type = types.str;
            };

          };

        });

    };

  };

  ###### implementation

  config = mkIf cfg.enable {
    systemd.services.xinetd = {
      after = [ "network.target" ];
      description = "xinetd server";
      path = [ pkgs.xinetd ];
      script = "exec xinetd -syslog daemon -dontfork -stayalive -f ${configFile}";
      wantedBy = [ "multi-user.target" ];
    };
  };
}
