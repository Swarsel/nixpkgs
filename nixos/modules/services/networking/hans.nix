# NixOS module for hans, ip over icmp daemon
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hans;

  hansUser = "hans";

in
{

  ### configuration

  options = {

    services.hans = {
      clients = lib.mkOption {
        default = { };

        description = ''
          Each attribute of this option defines a systemd service that
          runs hans. Many or none may be defined.
          The name of each service is
          `hans-«name»`
          where «name» is the name of the
          corresponding attribute name.
        '';

        example = lib.literalExpression ''
          {
            foo = {
              server = "192.0.2.1";
              extraConfig = "-v";
            }
          }
        '';

        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              extraConfig = lib.mkOption {
                default = "";
                description = "Additional command line parameters";
                example = "-v";
                type = lib.types.str;
              };

              passwordFile = lib.mkOption {
                default = "";
                description = "File that contains password";
                type = lib.types.str;
              };

              server = lib.mkOption {
                default = "";
                description = "IP address of server running hans";
                example = "192.0.2.1";
                type = lib.types.str;
              };

            };
          }
        );
      };

      server = {
        enable = lib.mkOption {
          default = false;
          description = "enable hans server";
          type = lib.types.bool;
        };

        extraConfig = lib.mkOption {
          default = "";
          description = "Additional command line parameters";
          example = "-v";
          type = lib.types.str;
        };

        ip = lib.mkOption {
          default = "";
          description = "The assigned ip range";
          example = "198.51.100.0";
          type = lib.types.str;
        };

        passwordFile = lib.mkOption {
          default = "";
          description = "File that contains password";
          type = lib.types.str;
        };

        respondToSystemPings = lib.mkOption {
          default = false;
          description = "Force hans respond to ordinary pings";
          type = lib.types.bool;
        };
      };

    };
  };

  ### implementation

  config = lib.mkIf (cfg.server.enable || cfg.clients != { }) {
    boot.kernel.sysctl = lib.optionalAttrs cfg.server.respondToSystemPings {
      "net.ipv4.icmp_echo_ignore_all" = 1;
    };

    boot.kernelModules = [ "tun" ];

    systemd.services =
      let
        createHansClientService = name: cfg: {
          after = [ "network.target" ];
          description = "hans client - ${name}";

          script = "${pkgs.hans}/bin/hans -f -u ${hansUser} ${cfg.extraConfig} -c ${cfg.server} ${
            lib.optionalString (cfg.passwordFile != "") "-p $(cat \"${cfg.passwordFile}\")"
          }";

          serviceConfig = {
            Restart = "always";
            RestartSec = "30s";
          };

          wantedBy = [ "multi-user.target" ];
        };
      in
      lib.listToAttrs (
        lib.mapAttrsToList (
          name: value: lib.nameValuePair "hans-${name}" (createHansClientService name value)
        ) cfg.clients
      )
      // {
        hans = lib.mkIf (cfg.server.enable) {
          after = [ "network.target" ];
          description = "hans, ip over icmp server daemon";

          script = "${pkgs.hans}/bin/hans -f -u ${hansUser} ${cfg.server.extraConfig} -s ${cfg.server.ip} ${lib.optionalString cfg.server.respondToSystemPings "-r"} ${
            lib.optionalString (cfg.server.passwordFile != "") "-p $(cat \"${cfg.server.passwordFile}\")"
          }";

          wantedBy = [ "multi-user.target" ];
        };
      };

    users.users.${hansUser} = {
      description = "Hans daemon user";
      isSystemUser = true;
    };
  };

  meta.maintainers = [ ];
}
