{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.pfix-srsd;
in
{

  ###### interface

  options = {

    services.pfix-srsd = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to run the postfix sender rewriting scheme daemon.";
        type = lib.types.bool;
      };

      configurePostfix = lib.mkOption {
        default = true;

        description = ''
          Whether to configure the required settings to use pfix-srsd in the local Postfix instance.
        '';

        type = lib.types.bool;
      };

      domain = lib.mkOption {
        description = "The domain for which to enable srs";
        example = "example.com";
        type = lib.types.str;
      };

      secretsFile = lib.mkOption {
        default = "/var/lib/pfix-srsd/secrets";

        description = ''
          The secret data used to encode the SRS address.
          to generate, use a command like:
          `for n in $(seq 5); do dd if=/dev/urandom count=1 bs=1024 status=none | sha256sum | sed 's/  -$//' | sed 's/^/          /'; done`
        '';

        type = lib.types.path;
      };
    };
  };

  ###### implementation

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.configurePostfix && config.services.postfix.enable) {
      services.postfix.settings.main = {
        recipient_canonical_classes = [ "envelope_recipient" ];
        recipient_canonical_maps = [ "tcp:127.0.0.1:10002" ];
        sender_canonical_classes = [ "envelope_sender" ];
        sender_canonical_maps = [ "tcp:127.0.0.1:10001" ];
      };
    })

    (lib.mkIf cfg.enable {
      environment = {
        systemPackages = [ pkgs.pfixtools ];
      };

      systemd.services.pfix-srsd = {
        before = [ "postfix.service" ];
        description = "Postfix sender rewriting scheme daemon";
        #note that we use requires rather than wants because postfix
        #is unable to process (almost) all mail without srsd
        requiredBy = [ "postfix.service" ];

        serviceConfig = {
          ExecStart = "${pkgs.pfixtools}/bin/pfix-srsd -p /run/pfix-srsd.pid -I ${config.services.pfix-srsd.domain} ${config.services.pfix-srsd.secretsFile}";
          PIDFile = "/run/pfix-srsd.pid";
          Type = "forking";
        };
      };
    })
  ];
}
