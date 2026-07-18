{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkRenamedOptionModule
    types
    ;

  cfg = config.users.ldap;

  # Careful: OpenLDAP seems to be very picky about the indentation of
  # this file.  Directives HAVE to start in the first column!
  ldapConfig = {
    source = pkgs.writeText "ldap.conf" ''
      uri ${config.users.ldap.server}
      base ${config.users.ldap.base}
      timelimit ${toString config.users.ldap.timeLimit}
      bind_timelimit ${toString config.users.ldap.bind.timeLimit}
      bind_policy ${config.users.ldap.bind.policy}
      ${lib.optionalString config.users.ldap.useTLS ''
        ssl start_tls
      ''}
      ${lib.optionalString (config.users.ldap.bind.distinguishedName != "") ''
        binddn ${config.users.ldap.bind.distinguishedName}
      ''}
      ${lib.optionalString (cfg.extraConfig != "") cfg.extraConfig}
    '';

    target = "ldap.conf";
  };

  nslcdConfig = pkgs.writeText "nslcd.conf" ''
    uri ${cfg.server}
    base ${cfg.base}
    timelimit ${toString cfg.timeLimit}
    bind_timelimit ${toString cfg.bind.timeLimit}
    ${lib.optionalString (cfg.bind.distinguishedName != "") "binddn ${cfg.bind.distinguishedName}"}
    ${lib.optionalString (cfg.daemon.rootpwmoddn != "") "rootpwmoddn ${cfg.daemon.rootpwmoddn}"}
    ${lib.optionalString (cfg.daemon.extraConfig != "") cfg.daemon.extraConfig}
  '';

  # nslcd normally reads configuration from /etc/nslcd.conf.
  # this file might contain secrets. We append those at runtime,
  # so redirect its location to something more temporary.
  nslcdWrapped = pkgs.runCommand "nslcd-wrapped" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.nss_pam_ldapd}/sbin/nslcd $out/bin/nslcd \
      --set LD_PRELOAD    "${pkgs.libredirect}/lib/libredirect.so" \
      --set NIX_REDIRECTS "/etc/nslcd.conf=/run/nslcd/nslcd.conf"
  '';

in

{

  imports = [
    (mkRenamedOptionModule
      [ "users" "ldap" "bind" "password" ]
      [ "users" "ldap" "bind" "passwordFile" ]
    )
  ];

  ###### interface
  options = {

    users.ldap = {

      enable = mkEnableOption "authentication against an LDAP server";

      base = mkOption {
        description = "The distinguished name of the search base.";
        example = "dc=example,dc=org";
        type = types.str;
      };

      bind = {
        distinguishedName = mkOption {
          default = "";

          description = ''
            The distinguished name to bind to the LDAP server with. If this
            is not specified, an anonymous bind will be done.
          '';

          example = "cn=admin,dc=example,dc=com";
          type = types.str;
        };

        passwordFile = mkOption {
          default = "/etc/ldap/bind.password";

          description = ''
            The path to a file containing the credentials to use when binding
            to the LDAP server (if not binding anonymously).
          '';

          type = types.str;
        };

        policy = mkOption {
          default = "hard_open";

          description = ''
            Specifies the policy to use for reconnecting to an unavailable
            LDAP server. The default is `hard_open`, which
            reconnects if opening the connection to the directory server
            failed. By contrast, `hard_init` reconnects if
            initializing the connection failed. Initializing may not
            actually contact the directory server, and it is possible that
            a malformed configuration file will trigger reconnection. If
            `soft` is specified, then
            `nss_ldap` will return immediately on server
            failure. All hard reconnect policies block with exponential
            backoff before retrying.
          '';

          type = types.enum [
            "hard_open"
            "hard_init"
            "soft"
          ];
        };

        timeLimit = mkOption {
          default = 30;

          description = ''
            Specifies the time limit (in seconds) to use when connecting
            to the directory server. This is distinct from the time limit
            specified in {option}`users.ldap.timeLimit` and affects
            the initial server connection only.
          '';

          type = types.int;
        };
      };

      daemon = {
        enable = mkOption {
          default = false;

          description = ''
            Whether to let the nslcd daemon (nss-pam-ldapd) handle the
            LDAP lookups for NSS and PAM. This can improve performance,
            and if you need to bind to the LDAP server with a password,
            it increases security, since only the nslcd user needs to
            have access to the bindpw file, not everyone that uses NSS
            and/or PAM. If this option is enabled, a local nscd user is
            created automatically, and the nslcd service is started
            automatically when the network get up.
          '';

          type = types.bool;
        };

        extraConfig = mkOption {
          default = "";

          description = ''
            Extra configuration options that will be added verbatim at
            the end of the nslcd configuration file ({manpage}`nslcd.conf(5)`).
          '';

          type = types.lines;
        };

        rootpwmoddn = mkOption {
          default = "";

          description = ''
            The distinguished name to use to bind to the LDAP server
            when the root user tries to modify a user's password.
          '';

          example = "cn=admin,dc=example,dc=com";
          type = types.str;
        };

        rootpwmodpwFile = mkOption {
          default = "";

          description = ''
            The path to a file containing the credentials with which to bind to
            the LDAP server if the root user tries to change a user's password.
          '';

          example = "/run/keys/nslcd.rootpwmodpw";
          type = types.str;
        };
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Extra configuration options that will be added verbatim at
          the end of the ldap configuration file ({manpage}`ldap.conf(5)`).
          If {option}`users.ldap.daemon` is enabled, this
          configuration will not be used. In that case, use
          {option}`users.ldap.daemon.extraConfig` instead.
        '';

        type = types.lines;
      };

      loginPam = mkOption {
        default = true;
        description = "Whether to include authentication against LDAP in login PAM.";
        type = types.bool;
      };

      nsswitch = mkOption {
        default = true;
        description = "Whether to include lookup against LDAP in NSS.";
        type = types.bool;
      };

      server = mkOption {
        description = "The URL of the LDAP server.";
        example = "ldap://ldap.example.org/";
        type = types.str;
      };

      timeLimit = mkOption {
        default = 0;

        description = ''
          Specifies the time limit (in seconds) to use when performing
          searches. A value of zero (0), which is the default, is to
          wait indefinitely for searches to be completed.
        '';

        type = types.int;
      };

      useTLS = mkOption {
        default = false;

        description = ''
          If enabled, use TLS (encryption) over an LDAP (port 389)
          connection.  The alternative is to specify an LDAPS server (port
          636) in {option}`users.ldap.server` or to forego
          security.
        '';

        type = types.bool;
      };

    };

  };

  ###### implementation
  config = mkIf cfg.enable {

    environment.etc = lib.optionalAttrs (!cfg.daemon.enable) {
      "ldap.conf" = ldapConfig;
    };

    system.nssDatabases.group = lib.optional cfg.nsswitch "ldap";
    system.nssDatabases.passwd = lib.optional cfg.nsswitch "ldap";
    system.nssDatabases.shadow = lib.optional cfg.nsswitch "ldap";

    system.nssModules = mkIf cfg.nsswitch (
      lib.singleton (if cfg.daemon.enable then pkgs.nss_pam_ldapd else pkgs.nss_ldap)
    );

    systemd.services = mkMerge [
      (mkIf (!cfg.daemon.enable) {
        ldap-password = {
          before = [
            "sysinit.target"
            "shutdown.target"
          ];

          conflicts = [ "shutdown.target" ];

          script = ''
            if test -f "${cfg.bind.passwordFile}" ; then
              umask 0077
              conf="$(mktemp)"
              printf 'bindpw %s\n' "$(cat ${cfg.bind.passwordFile})" |
              cat ${ldapConfig.source} - >"$conf"
              mv -fT "$conf" /etc/ldap.conf
            fi
          '';

          serviceConfig.RemainAfterExit = true;
          serviceConfig.Type = "oneshot";
          unitConfig.DefaultDependencies = false;
          wantedBy = [ "sysinit.target" ];
        };
      })

      (mkIf cfg.daemon.enable {
        nslcd = {
          preStart = ''
            umask 0077
            conf="$(mktemp)"
            {
              cat ${nslcdConfig}
              test -z '${cfg.bind.distinguishedName}' -o ! -f '${cfg.bind.passwordFile}' ||
              printf 'bindpw %s\n' "$(cat '${cfg.bind.passwordFile}')"
              test -z '${cfg.daemon.rootpwmoddn}' -o ! -f '${cfg.daemon.rootpwmodpwFile}' ||
              printf 'rootpwmodpw %s\n' "$(cat '${cfg.daemon.rootpwmodpwFile}')"
            } >"$conf"
            mv -fT "$conf" /run/nslcd/nslcd.conf
          '';

          restartTriggers = [
            nslcdConfig
            cfg.bind.passwordFile
            cfg.daemon.rootpwmodpwFile
          ];

          serviceConfig = {
            AmbientCapabilities = "CAP_SYS_RESOURCE";
            ExecStart = "${nslcdWrapped}/bin/nslcd";
            Group = "nslcd";
            PIDFile = "/run/nslcd/nslcd.pid";
            Restart = "always";
            RuntimeDirectory = [ "nslcd" ];
            Type = "forking";
            User = "nslcd";
          };

          wantedBy = [ "multi-user.target" ];
        };
      })
    ];

    users = mkIf cfg.daemon.enable {
      groups.nslcd = {
        gid = config.ids.gids.nslcd;
      };

      users.nslcd = {
        description = "nslcd user.";
        group = "nslcd";
        uid = config.ids.uids.nslcd;
      };
    };

  };
}
