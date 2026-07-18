{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.mail-tlsa-check;

  inherit (lib)
    boolToString
    collect
    concatStringsSep
    getExe
    isBool
    isList
    isString
    listToAttrs
    mapAttrsRecursive
    mkForce
    mkOption
    mkPackageOption
    optionalAttrs
    pipe
    toUpper
    types
    ;

  environment = pipe cfg.settings [
    (mapAttrsRecursive (
      path: value:
      optionalAttrs (value != null) {
        name = toUpper "MTCE_${concatStringsSep "_" path}";

        value =
          if isList value then
            concatStringsSep "," value
          else if isBool value then
            boolToString value
          else
            toString value;
      }
    ))
    (collect (x: isString x.name or false && isString x.value or false))
    listToAttrs
  ];
in
{
  assertions = [
    {
      assertion = cfg.settings.ipv4.enabled || cfg.ipv6.enabled;
      message = "Both IPv4 and IPv6 are disabled, this is not possible as it won't monitor anything";
    }
    {
      assertion = cfg.settings.smtp.hostname != null || cfg.settings.imap.hostname != null;
      message = "Both SMTP and IMAP are disabled, this is not possible as it won't monitor anything";
    }
  ];

  extraOpts = {
    package = mkPackageOption pkgs "mail-tlsa-check-exporter" { };

    settings = mkOption {
      description = "Settings for the mail-tlsa-check-exporter";

      type = types.submodule {
        options = {
          check.timeout = mkOption {
            default = 15000;
            description = "Timeout for validation checks to complete before giving up, in milliseconds (e.g. 15000 for 15 seconds)";
            example = 10000;
            type = types.ints.positive;
          };

          imap = {
            hostname = mkOption {
              default = null;
              description = "The IMAP hostname to monitor";
              example = "imap.example.org";
              type = types.nullOr types.str;
            };

            port = mkOption {
              default = 143;

              description = ''
                The IMAP port to monitor

                ::: {.note}
                The exporter currently only supports explicit TLS (StartTLS), see <https://github.com/ietf-tools/mail-tlsa-check-exporter/issues/6>
                :::
              '';

              type = types.port;
            };
          };

          ipv4.enabled = mkOption {
            default = true;
            description = "Whether to enable monitoring over IPv4";
            example = false;
            type = types.bool;
          };

          ipv6.enabled = mkOption {
            default = true;
            description = "Whether to enable monitoring over IPv6";
            example = false;
            type = types.bool;
          };

          server.port = mkOption {
            default = cfg.port;
            defaultText = lib.literalExpression "config.services.prometheus.exporters.mail-tlsa-check.port";

            description = ''
              The port that the exporter listens on.

              ::: {.note}
              This is a read-only option that is read from {option}`services.prometheus.exporters.mail-tlsa-check.port`.
              :::
            '';

            readOnly = true;
            type = types.port;
          };

          smtp = {
            client = mkOption {
              default = "tlsa-smtp-synthetics-probe";
              description = "The host to send in the SMTP EHLO command (name/domain/IP address)";
              example = "tlsa-exporter";
              type = types.str;
            };

            hostname = mkOption {
              default = null;
              description = "The SMTP hostname to monitor";
              example = "smtp.example.org";
              type = types.nullOr types.str;
            };

            port = mkOption {
              default = 587;

              description = ''
                The SMTP port to monitor

                ::: {.note}
                The exporter currently only supports explicit TLS (StartTLS), see <https://github.com/ietf-tools/mail-tlsa-check-exporter/issues/6>
                :::
              '';

              example = 465;
              type = types.port;
            };
          };

          tlsa.record = mkOption {
            description = "The TLSA record to monitor";
            example = "_25._tcp.smtp.example.org";
            type = types.str;
          };
        };

        freeformType = types.attrs;
      };
    };
  };

  port = 19309;

  serviceOpts = {
    inherit environment;

    serviceConfig = {
      ExecStart = getExe cfg.package;
      MemoryDenyWriteExecute = mkForce false; # because v8 won't start otherwise
      Restart = "always"; # because apparently, this service crashes and is intended to do so, see the upstream systemd unit
    };
  };
}
