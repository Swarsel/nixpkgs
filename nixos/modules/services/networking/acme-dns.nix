{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.acme-dns;
  format = pkgs.formats.toml { };
  inherit (lib)
    literalExpression
    mkEnableOption
    mkOption
    mkPackageOption
    types
    ;
  domain = "acme-dns.example.com";
in
{
  options.services.acme-dns = {
    enable = mkEnableOption "acme-dns";
    package = mkPackageOption pkgs "acme-dns" { };

    settings = mkOption {
      default = { };

      description = ''
        Free-form settings written directly to the `acme-dns.cfg` file.
        Refer to <https://github.com/joohoi/acme-dns/blob/master/README.md#configuration> for supported values.
      '';

      type = types.submodule {
        options = {
          api = {
            disable_registration = mkOption {
              default = false;
              description = "Whether to disable the HTTP registration endpoint.";
              example = true;
              type = types.bool;
            };

            ip = mkOption {
              default = "[::]";
              description = "IP to bind the HTTP API on.";
              example = "127.0.0.1";
              type = types.str;
            };

            port = mkOption {
              # acme-dns expects this value to be a string
              apply = toString;
              default = 8080;
              description = "Listen port for the HTTP API.";
              type = types.port;
            };

            tls = mkOption {
              default = "none";
              description = "TLS backend to use.";

              type = types.enum [
                "letsencrypt"
                "letsencryptstaging"
                "cert"
                "none"
              ];
            };
          };

          database = {
            connection = mkOption {
              default = "/var/lib/acme-dns/acme-dns.db";
              description = "Database connection string.";
              example = "postgres://user:password@localhost/acmedns";
              type = types.str;
            };

            engine = mkOption {
              default = "sqlite";
              description = "Database engine to use.";

              type = types.enum [
                "sqlite"
                "postgres"
              ];
            };
          };

          general = {
            domain = mkOption {
              description = "Domain name to serve the requests off of.";
              example = domain;
              type = types.str;
            };

            listen = mkOption {
              default = "[::]:53";
              description = "IP+port combination to bind and serve the DNS server on.";
              example = "127.0.0.1:53";
              type = types.str;
            };

            nsadmin = mkOption {
              description = "Zone admin email address for `SOA`.";
              example = "admin.example.com";
              type = types.str;
            };

            nsname = mkOption {
              description = "Zone name server.";
              example = domain;
              type = types.str;
            };

            protocol = mkOption {
              default = "both";
              description = "Protocols to serve DNS responses on.";

              type = types.enum [
                "both"
                "both4"
                "both6"
                "udp"
                "udp4"
                "udp6"
                "tcp"
                "tcp4"
                "tcp6"
              ];
            };

            records = mkOption {
              description = "Predefined DNS records served in addition to the `_acme-challenge` TXT records.";

              example = literalExpression ''
                [
                  # replace with your acme-dns server's public IPv4
                  "${domain}. A 198.51.100.1"
                  # replace with your acme-dns server's public IPv6
                  "${domain}. AAAA 2001:db8::1"
                  # ${domain} should resolve any *.${domain} records
                  "${domain}. NS ${domain}."
                ]
              '';

              type = types.listOf types.str;
            };
          };

          logconfig = {
            loglevel = mkOption {
              default = "info";
              description = "Level to log on.";

              type = types.enum [
                "error"
                "warning"
                "info"
                "debug"
              ];
            };
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.packages = [ cfg.package ];

    systemd.services.acme-dns = {
      serviceConfig = {
        DynamicUser = true;

        ExecStart = [
          ""
          "${lib.getExe cfg.package} -c ${format.generate "acme-dns.toml" cfg.settings}"
        ];

        StateDirectory = "acme-dns";
        WorkingDirectory = "%S/acme-dns";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
