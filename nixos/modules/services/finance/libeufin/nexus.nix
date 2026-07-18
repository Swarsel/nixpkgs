{
  config,
  lib,
  options,
  ...
}:
{
  imports = [ (import ./common.nix "nexus") ];

  options.services.libeufin.nexus.settings = lib.mkOption {
    description = ''
      Configuration options for the libeufin nexus config file.

      For a list of all possible options, please see the man page [`libeufin-nexus.conf(5)`](https://docs.taler.net/manpages/libeufin-nexus.conf.5.html)
    '';

    type = lib.types.submodule {
      inherit (options.services.libeufin.settings.type.nestedTypes) freeformType;

      options = {
        libeufin-nexusdb-postgres = {
          CONFIG = lib.mkOption {
            description = ''
              The database connection string for the libeufin-nexus database.
            '';

            type = lib.types.str;
          };
        };

        nexus-ebics = {
          BANK_DIALECT = lib.mkOption {
            description = ''
              Name of the following combination: EBICS version and ISO20022
              recommendations that Nexus would honor in the communication with the
              bank.

              Currently only the "postfinance" or "gls" value is supported.
            '';

            example = "postfinance";

            type = lib.types.enum [
              "postfinance"
              "gls"
            ];
          };

          BANK_PUBLIC_KEYS_FILE = lib.mkOption {
            default = "/var/lib/libeufin-nexus/bank-ebics-keys.json";

            description = ''
              Filesystem location where Nexus should store the bank public keys.
            '';

            type = lib.types.path;
          };

          BIC = lib.mkOption {
            description = "BIC of the bank account that is associated with the EBICS subscriber.";
            example = "POFICHBEXXX";
            type = lib.types.nonEmptyStr;
          };

          CLIENT_PRIVATE_KEYS_FILE = lib.mkOption {
            default = "/var/lib/libeufin-nexus/client-ebics-keys.json";

            description = ''
              Filesystem location where Nexus should store the subscriber private keys.
            '';

            type = lib.types.path;
          };

          # Mandatory configuration values
          # https://docs.taler.net/libeufin/nexus-manual.html#setting-up-the-ebics-subscriber
          # https://docs.taler.net/libeufin/setup-ebics-at-postfinance.html
          CURRENCY = lib.mkOption {
            description = "Name of the fiat currency.";
            example = "CHF";
            type = lib.types.nonEmptyStr;
          };

          HOST_BASE_URL = lib.mkOption {
            description = "URL of the EBICS server.";
            example = "https://ebics.postfinance.ch/ebics/ebics.aspx";
            type = lib.types.nonEmptyStr;
          };

          HOST_ID = lib.mkOption {
            description = "Name of the EBICS host.";
            example = "PFEBICS";
            type = lib.types.nonEmptyStr;
          };

          IBAN = lib.mkOption {
            description = "IBAN of the bank account that is associated with the EBICS subscriber.";
            example = "CH7789144474425692816";
            type = lib.types.nonEmptyStr;
          };

          NAME = lib.mkOption {
            description = "Legal entity that is associated with the EBICS subscriber.";
            example = "John Smith S.A.";
            type = lib.types.nonEmptyStr;
          };

          PARTNER_ID = lib.mkOption {
            description = ''
              Partner ID of the EBICS subscriber.

              This value must be assigned by the bank after having activated a new EBICS subscriber.
            '';

            example = "PFC00563";
            type = lib.types.nonEmptyStr;
          };

          USER_ID = lib.mkOption {
            description = ''
              User ID of the EBICS subscriber.

              This value must be assigned by the bank after having activated a new EBICS subscriber.
            '';

            example = "PFC00563";
            type = lib.types.nonEmptyStr;
          };
        };

        nexus-httpd = {
          PORT = lib.mkOption {
            default = 8084;

            description = ''
              The port on which libeufin-bank should listen.
            '';

            type = lib.types.port;
          };
        };
      };
    };
  };

  config =
    let
      cfgMain = config.services.libeufin;
      cfg = config.services.libeufin.nexus;
    in
    lib.mkIf cfg.enable {
      services.libeufin.nexus.settings.libeufin-nexusdb-postgres.CONFIG = lib.mkIf (
        cfgMain.bank.enable && cfgMain.bank.createLocalDatabase
      ) "postgresql:///libeufin-bank";

      systemd.services.libeufin-nexus.documentation = [ "man:libeufin-nexus(1)" ];
    };
}
