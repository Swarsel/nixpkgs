{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.cfssl;
in
{
  options.services.cfssl = {
    enable = lib.mkEnableOption "the CFSSL CA api-server";

    address = lib.mkOption {
      default = "127.0.0.1";
      description = "Address to bind.";
      type = lib.types.str;
    };

    ca = lib.mkOption {
      defaultText = lib.literalExpression ''"''${cfg.dataDir}/ca.pem"'';
      description = "CA used to sign the new certificate -- accepts '[file:]fname' or 'env:varname'.";
      type = lib.types.str;
    };

    caBundle = lib.mkOption {
      default = null;
      description = "Path to root certificate store.";
      type = lib.types.nullOr lib.types.path;
    };

    caKey = lib.mkOption {
      defaultText = lib.literalExpression ''"file:''${cfg.dataDir}/ca-key.pem"'';
      description = "CA private key -- accepts '[file:]fname' or 'env:varname'.";
      type = lib.types.str;
    };

    configFile = lib.mkOption {
      default = null;
      description = "Path to configuration file. Do not put this in nix-store as it might contain secrets.";
      type = lib.types.nullOr lib.types.str;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/cfssl";

      description = ''
        The work directory for CFSSL.

        ::: {.note}
        If left as the default value this directory will automatically be
        created before the CFSSL server starts, otherwise you are
        responsible for ensuring the directory exists with appropriate
        ownership and permissions.
        :::
      '';

      type = lib.types.path;
    };

    dbConfig = lib.mkOption {
      default = null;
      description = "Certificate db configuration file. Path must be writeable.";
      type = lib.types.nullOr lib.types.path;
    };

    disable = lib.mkOption {
      default = null;
      description = "Endpoints to disable (comma-separated list)";
      type = lib.types.nullOr lib.types.commas;
    };

    intBundle = lib.mkOption {
      default = null;
      description = "Path to intermediate certificate store.";
      type = lib.types.nullOr lib.types.path;
    };

    intDir = lib.mkOption {
      default = null;
      description = "Intermediates directory.";
      type = lib.types.nullOr lib.types.path;
    };

    logLevel = lib.mkOption {
      default = 1;
      description = "Log level (0 = DEBUG, 5 = FATAL).";
      type = lib.types.ints.between 0 5;
    };

    metadata = lib.mkOption {
      default = null;

      description = ''
        Metadata file for root certificate presence.
        The content of the file is a json dictionary (k,v): each key k is
        a SHA-1 digest of a root certificate while value v is a list of key
        store filenames.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    mutualTlsCa = lib.mkOption {
      default = null;
      description = "Mutual TLS - require clients be signed by this CA.";
      type = lib.types.nullOr lib.types.path;
    };

    mutualTlsClientCert = lib.mkOption {
      default = null;
      description = "Mutual TLS - client certificate to call remote instance requiring client certs.";
      type = lib.types.nullOr lib.types.path;
    };

    mutualTlsClientKey = lib.mkOption {
      default = null;
      description = "Mutual TLS - client key to call remote instance requiring client certs. Do not put this in nix-store.";
      type = lib.types.nullOr lib.types.path;
    };

    mutualTlsCn = lib.mkOption {
      default = null;
      description = "Mutual TLS - regex for whitelist of allowed client CNs.";
      type = lib.types.nullOr lib.types.str;
    };

    port = lib.mkOption {
      default = 8888;
      description = "Port to bind.";
      type = lib.types.port;
    };

    remote = lib.mkOption {
      default = null;
      description = "Remote CFSSL server.";
      type = lib.types.nullOr lib.types.str;
    };

    responder = lib.mkOption {
      default = null;
      description = "Certificate for OCSP responder.";
      type = lib.types.nullOr lib.types.path;
    };

    responderKey = lib.mkOption {
      default = null;
      description = "Private key for OCSP responder certificate. Do not put this in nix-store.";
      type = lib.types.nullOr lib.types.str;
    };

    tlsCert = lib.mkOption {
      default = null;
      description = "Other endpoint's CA to set up TLS protocol.";
      type = lib.types.nullOr lib.types.path;
    };

    tlsKey = lib.mkOption {
      default = null;
      description = "Other endpoint's CA private key. Do not put this in nix-store.";
      type = lib.types.nullOr lib.types.str;
    };

    tlsRemoteCa = lib.mkOption {
      default = null;
      description = "CAs to trust for remote TLS requests.";
      type = lib.types.nullOr lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    services.cfssl = {
      ca = lib.mkDefault "${cfg.dataDir}/ca.pem";
      caKey = lib.mkDefault "${cfg.dataDir}/ca-key.pem";
    };

    systemd.services.cfssl = {
      after = [ "network.target" ];
      description = "CFSSL CA API server";

      serviceConfig = lib.mkMerge [
        {
          ExecStart =
            with cfg;
            let
              opt = n: v: lib.optionalString (v != null) ''-${n}="${v}"'';
            in
            lib.concatStringsSep " \\\n" [
              "${pkgs.cfssl}/bin/cfssl serve"
              (opt "address" address)
              (opt "port" (toString port))
              (opt "ca" ca)
              (opt "ca-key" caKey)
              (opt "ca-bundle" caBundle)
              (opt "int-bundle" intBundle)
              (opt "int-dir" intDir)
              (opt "metadata" metadata)
              (opt "remote" remote)
              (opt "config" configFile)
              (opt "responder" responder)
              (opt "responder-key" responderKey)
              (opt "tls-key" tlsKey)
              (opt "tls-cert" tlsCert)
              (opt "mutual-tls-ca" mutualTlsCa)
              (opt "mutual-tls-cn" mutualTlsCn)
              (opt "mutual-tls-client-key" mutualTlsClientKey)
              (opt "mutual-tls-client-cert" mutualTlsClientCert)
              (opt "tls-remote-ca" tlsRemoteCa)
              (opt "db-config" dbConfig)
              (opt "loglevel" (toString logLevel))
              (opt "disable" disable)
            ];

          Group = "cfssl";
          Restart = "always";
          User = "cfssl";
          WorkingDirectory = cfg.dataDir;
        }
        (lib.mkIf (cfg.dataDir == options.services.cfssl.dataDir.default) {
          StateDirectory = baseNameOf cfg.dataDir;
          StateDirectoryMode = 700;
        })
      ];

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.cfssl = {
      gid = config.ids.gids.cfssl;
    };

    users.users.cfssl = {
      description = "cfssl user";
      group = "cfssl";
      home = cfg.dataDir;
      uid = config.ids.uids.cfssl;
    };
  };
}
