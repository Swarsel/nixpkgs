{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.security.ipa;

  ldapConf = pkgs.writeText "ldap.conf" ''
    # Turning this off breaks GSSAPI used with krb5 when rdns = false
    SASL_NOCANON    on

    URI ldaps://${cfg.server}
    BASE ${cfg.basedn}
    TLS_CACERT /etc/ipa/ca.crt
  '';
  nssDb =
    pkgs.runCommand "ipa-nssdb"
      {
        nativeBuildInputs = [ pkgs.nss.tools ];
      }
      ''
        mkdir -p $out
        certutil -d $out -N --empty-password
        certutil -d $out -A --empty-password -n "${cfg.realm} IPA CA" -t CT,C,C -i ${cfg.certificate}
      '';
in
{
  options = {
    security.ipa = {
      enable = lib.mkEnableOption "FreeIPA domain integration";

      basedn = lib.mkOption {
        description = "Base DN to use when performing LDAP operations.";
        example = "dc=example,dc=com";
        type = lib.types.str;
      };

      cacheCredentials = lib.mkOption {
        default = true;
        description = "Whether to cache credentials.";
        type = lib.types.bool;
      };

      certificate = lib.mkOption {
        description = ''
          IPA server CA certificate.

          Use `nix-prefetch-url http://$server/ipa/config/ca.crt` to
          obtain the file and the hash.
        '';

        example = lib.literalExpression ''
          pkgs.fetchurl {
            url = "http://ipa.example.com/ipa/config/ca.crt";
            hash = lib.fakeHash;
          };
        '';

        type = lib.types.package;
      };

      chromiumSupport = lib.mkOption {
        default = true;
        description = "Whether to whitelist the FreeIPA domain in Chromium.";
        type = lib.types.bool;
      };

      domain = lib.mkOption {
        description = "Domain of the IPA server.";
        example = "example.com";
        type = lib.types.str;
      };

      dyndns = {
        enable = lib.mkOption {
          default = true;
          description = "Whether to enable FreeIPA automatic hostname updates.";
          type = lib.types.bool;
        };

        interface = lib.mkOption {
          default = "*";
          description = "Network interface to perform hostname updates through.";
          example = "eth0";
          type = lib.types.str;
        };
      };

      ifpAllowedUids = lib.mkOption {
        default = [ "root" ];
        description = "A list of users allowed to access the ifp dbus interface.";
        type = lib.types.listOf lib.types.str;
      };

      ipaHostname = lib.mkOption {
        default =
          if config.networking.domain != null then
            config.networking.fqdn
          else
            "${config.networking.hostName}.${cfg.domain}";

        defaultText = lib.literalExpression ''
          if config.networking.domain != null then config.networking.fqdn
          else "''${networking.hostName}.''${security.ipa.domain}"
        '';

        description = "Fully-qualified hostname used to identify this host in the IPA domain.";
        example = "myworkstation.example.com";
        type = lib.types.str;
      };

      offlinePasswords = lib.mkOption {
        default = true;
        description = "Whether to store offline passwords when the server is down.";
        type = lib.types.bool;
      };

      realm = lib.mkOption {
        description = "Kerberos realm.";
        example = "EXAMPLE.COM";
        type = lib.types.str;
      };

      server = lib.mkOption {
        description = "IPA Server hostname.";
        example = "ipa.example.com";
        type = lib.types.str;
      };

      shells = lib.mkOption {
        default = with pkgs; [
          bash
          zsh
        ];

        defaultText = lib.literalExpression ''
          with pkgs; [ bash zsh ];
        '';

        description = ''
          List of shells which binaries should be installed to /bin/<name>.

          FreeIPA typicly configures somesthing like /bin/bash into the users shell attribute.
        '';

        type = lib.types.listOf lib.types.package;
      };

      useAsTimeserver = lib.mkOption {
        default = true;
        description = "Whether to add the IPA server to the timeserver.";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.security.krb5.enable;
        message = "krb5 must be disabled through `security.krb5.enable` for FreeIPA integration to work.";
      }
      {
        assertion = !config.users.ldap.enable;
        message = "ldap must be disabled through `users.ldap.enable` for FreeIPA integration to work.";
      }
    ];

    environment.etc = {
      "chromium/policies/managed/freeipa.json" = lib.mkIf cfg.chromiumSupport {
        text = builtins.toJSON {
          AuthServerWhitelist = "*.${cfg.domain}";
        };
      };

      "ipa/default.conf".text = lib.generators.toINI { } {
        global = {
          inherit (cfg)
            basedn
            realm
            domain
            server
            ;

          enable_ra = "True";
          host = cfg.ipaHostname;
          xmlrpc_uri = "https://${cfg.server}/ipa/xml";
        };
      };

      "ipa/nssdb".source = nssDb;

      "krb5.conf".text = ''
        [libdefaults]
         default_realm = ${cfg.realm}
         dns_lookup_realm = false
         dns_lookup_kdc = true
         rdns = false
         ticket_lifetime = 24h
         forwardable = true
         udp_preference_limit = 0

        [realms]
         ${cfg.realm} = {
          kdc = ${cfg.server}:88
          master_kdc = ${cfg.server}:88
          admin_server = ${cfg.server}:749
          default_domain = ${cfg.domain}
          pkinit_anchors = FILE:/etc/ipa/ca.crt
        }

        [domain_realm]
         .${cfg.domain} = ${cfg.realm}
         ${cfg.domain} = ${cfg.realm}
         ${cfg.server} = ${cfg.realm}

        [dbmodules]
          ${cfg.realm} = {
            db_library = ${pkgs.freeipa}/lib/krb5/plugins/kdb/ipadb.so
          }
      '';

      "ldap.conf".source = ldapConf;
    };

    environment.systemPackages = with pkgs; [
      krb5
      freeipa
    ];

    networking.timeServers = lib.optional cfg.useAsTimeserver cfg.server;
    security.pki.certificateFiles = lib.singleton cfg.certificate;

    services.sssd = {
      enable = true;

      settings = {
        autofs = { };

        "domain/${cfg.domain}" = {
          access_provider = "ipa";
          auth_provider = "ipa";
          cache_credentials = cfg.cacheCredentials;
          chpass_provider = "ipa";
          dyndns_iface = cfg.dyndns.interface;
          dyndns_update = cfg.dyndns.enable;
          id_provider = "ipa";
          ipa_domain = cfg.domain;
          ipa_hostname = cfg.ipaHostname;
          ipa_server = "_srv_, ${cfg.server}";
          krb5_realm = lib.mkIf ((lib.toLower cfg.domain) != (lib.toLower cfg.realm)) cfg.realm;
          krb5_store_password_if_offline = cfg.offlinePasswords;
          ldap_tls_cacert = "/etc/ipa/ca.crt";
          ldap_user_extra_attrs = "mail:mail, sn:sn, givenname:givenname, telephoneNumber:telephoneNumber, lock:nsaccountlock";
        };

        ifp = {
          allowed_uids = lib.concatStringsSep ", " cfg.ifpAllowedUids;
          user_attributes = "+mail, +telephoneNumber, +givenname, +sn, +lock";
        };

        nss.homedir_substring = "/home";
        pac = { };

        pam = {
          pam_pwd_expiration_warning = 3;
          pam_verbosity = 3;
        };

        ssh = { };

        sssd = {
          domains = cfg.domain;
          services = "nss, sudo, pam, ssh, ifp";
        };

        sudo = { };
      };

      subIDsIntegration = true;
    };

    systemd.services."ipa-activation" = {
      before = [
        "sysinit.target"
        "shutdown.target"
      ];

      conflicts = [ "shutdown.target" ];

      script = ''
        # libcurl requires a hard copy of the certificate
        if ! ${pkgs.diffutils}/bin/diff ${cfg.certificate} /etc/ipa/ca.crt > /dev/null 2>&1; then
          rm -f /etc/ipa/ca.crt
          cp ${cfg.certificate} /etc/ipa/ca.crt
        fi

        if [ ! -f /etc/krb5.keytab ]; then
          cat <<EOF

            In order to complete FreeIPA integration, please join the domain by completing the following steps:
            1. Authenticate as an IPA user authorized to join new hosts, e.g. kinit admin@${cfg.realm}
            2. Join the domain and obtain the keytab file: ipa-join
            3. Install the keytab file: sudo install -m 600 krb5.keytab /etc/
            4. Restart sssd systemd service: sudo systemctl restart sssd

        EOF
        # let service fail, to raise awareness
        exit 1
        fi
      '';

      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };

      unitConfig.DefaultDependencies = false;
      wantedBy = [ "sysinit.target" ];
    };

    systemd.tmpfiles.settings."10-ipa-shells" = lib.foldl' (
      acc: pkg:
      (
        acc
        // {
          ${pkg.shellPath}."L+".argument = "${pkg}${pkg.shellPath}";
        }
      )
    ) { } cfg.shells;
  };
}
