{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.nifi;
  opt = options.services.nifi;

  env = {
    NIFI_HOME = "/var/lib/nifi";
    NIFI_LOG_DIR = "/var/log/nifi";
    NIFI_OVERRIDE_NIFIENV = "true";
    NIFI_PID_DIR = "/run/nifi";
  };

  envFile = pkgs.writeText "nifi.env" (
    lib.concatMapStrings (s: s + "\n") (
      lib.concatLists (
        lib.mapAttrsToList (name: value: lib.optional (value != null) ''${name}="${toString value}"'') env
      )
    )

  );

  nifiEnv = pkgs.writeShellScriptBin "nifi-env" ''
    set -a
    source "${envFile}"
    eval -- "\$@"
  '';

in
{
  options = {
    services.nifi = {
      enable = lib.mkEnableOption "Apache NiFi";
      package = lib.mkPackageOption pkgs "nifi" { };

      enableHTTPS = lib.mkOption {
        default = true;
        description = "Enable HTTPS protocol. Don`t use in production.";
        type = lib.types.bool;
      };

      group = lib.mkOption {
        default = "nifi";
        description = "Group account where Apache NiFi runs.";
        type = lib.types.str;
      };

      initJavaHeapSize = lib.mkOption {
        default = null;
        description = "Set the initial heap size for the JVM in MB.";
        example = 1024;
        type = lib.types.nullOr lib.types.int;
      };

      initPasswordFile = lib.mkOption {
        default = null;
        description = "nitial password for Apache NiFi. Password must be at least 12 characters.";
        example = "/run/keys/nifi/password-nifi";
        type = lib.types.nullOr lib.types.path;
      };

      initUser = lib.mkOption {
        default = null;
        description = "Initial user account for Apache NiFi. Username must be at least 4 characters.";
        type = lib.types.nullOr lib.types.str;
      };

      listenHost = lib.mkOption {
        default = if cfg.enableHTTPS then "0.0.0.0" else "127.0.0.1";

        defaultText = lib.literalExpression ''
          if config.${opt.enableHTTPS}
          then "0.0.0.0"
          else "127.0.0.1"
        '';

        description = "Bind to an ip for Apache NiFi web-ui.";
        type = lib.types.str;
      };

      listenPort = lib.mkOption {
        default = if cfg.enableHTTPS then 8443 else 8080;

        defaultText = lib.literalExpression ''
          if config.${opt.enableHTTPS}
          then "8443"
          else "8000"
        '';

        description = "Bind to a port for Apache NiFi web-ui.";
        type = lib.types.port;
      };

      maxJavaHeapSize = lib.mkOption {
        default = null;
        description = "Set the initial heap size for the JVM in MB.";
        example = 2048;
        type = lib.types.nullOr lib.types.int;
      };

      proxyHost = lib.mkOption {
        default = if cfg.enableHTTPS then "0.0.0.0" else null;

        defaultText = lib.literalExpression ''
          if config.${opt.enableHTTPS}
          then "0.0.0.0"
          else null
        '';

        description = "Allow requests from a specific host.";
        type = lib.types.nullOr lib.types.str;
      };

      proxyPort = lib.mkOption {
        default = if cfg.enableHTTPS then 8443 else null;

        defaultText = lib.literalExpression ''
          if config.${opt.enableHTTPS}
          then "8443"
          else null
        '';

        description = "Allow requests from a specific port.";
        type = lib.types.nullOr lib.types.port;
      };

      user = lib.mkOption {
        default = "nifi";
        description = "User account where Apache NiFi runs.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.initUser != null || cfg.initPasswordFile == null;

        message = ''
          <option>services.nifi.initUser</option> needs to be set if <option>services.nifi.initPasswordFile</option> enabled.
        '';
      }
      {
        assertion = cfg.initUser == null || cfg.initPasswordFile != null;

        message = ''
          <option>services.nifi.initPasswordFile</option> needs to be set if <option>services.nifi.initUser</option> enabled.
        '';
      }
      {
        assertion = cfg.proxyHost == null || cfg.proxyPort != null;

        message = ''
          <option>services.nifi.proxyPort</option> needs to be set if <option>services.nifi.proxyHost</option> value specified.
        '';
      }
      {
        assertion = cfg.proxyHost != null || cfg.proxyPort == null;

        message = ''
          <option>services.nifi.proxyHost</option> needs to be set if <option>services.nifi.proxyPort</option> value specified.
        '';
      }
      {
        assertion = cfg.initJavaHeapSize == null || cfg.maxJavaHeapSize != null;

        message = ''
          <option>services.nifi.maxJavaHeapSize</option> needs to be set if <option>services.nifi.initJavaHeapSize</option> value specified.
        '';
      }
      {
        assertion = cfg.initJavaHeapSize != null || cfg.maxJavaHeapSize == null;

        message = ''
          <option>services.nifi.initJavaHeapSize</option> needs to be set if <option>services.nifi.maxJavaHeapSize</option> value specified.
        '';
      }
    ];

    systemd.services.nifi = {
      after = [ "network.target" ];
      description = "Apache NiFi";
      environment = env;
      path = [ pkgs.gawk ];

      serviceConfig = {
        # Capabilities
        CapabilityBoundingSet = "";
        ExecStart = "${cfg.package}/bin/nifi.sh start";

        ExecStartPre = pkgs.writeScript "nifi-pre-start.sh" ''
          #!/bin/sh
          umask 077
          test -f '/var/lib/nifi/conf/authorizers.xml'                      || (cp '${cfg.package}/share/nifi/conf/authorizers.xml' '/var/lib/nifi/conf/' && chmod 0640 '/var/lib/nifi/conf/authorizers.xml')
          test -f '/var/lib/nifi/conf/bootstrap.conf'                       || (cp '${cfg.package}/share/nifi/conf/bootstrap.conf' '/var/lib/nifi/conf/' && chmod 0640 '/var/lib/nifi/conf/bootstrap.conf')
          test -f '/var/lib/nifi/conf/bootstrap-hashicorp-vault.conf'       || (cp '${cfg.package}/share/nifi/conf/bootstrap-hashicorp-vault.conf' '/var/lib/nifi/conf/' && chmod 0640 '/var/lib/nifi/conf/bootstrap-hashicorp-vault.conf')
          test -f '/var/lib/nifi/conf/bootstrap-notification-services.xml'  || (cp '${cfg.package}/share/nifi/conf/bootstrap-notification-services.xml' '/var/lib/nifi/conf/' && chmod 0640 '/var/lib/nifi/conf/bootstrap-notification-services.xml')
          test -f '/var/lib/nifi/conf/logback.xml'                          || (cp '${cfg.package}/share/nifi/conf/logback.xml' '/var/lib/nifi/conf/' && chmod 0640 '/var/lib/nifi/conf/logback.xml')
          test -f '/var/lib/nifi/conf/login-identity-providers.xml'         || (cp '${cfg.package}/share/nifi/conf/login-identity-providers.xml' '/var/lib/nifi/conf/' && chmod 0640 '/var/lib/nifi/conf/login-identity-providers.xml')
          test -f '/var/lib/nifi/conf/nifi.properties'                      || (cp '${cfg.package}/share/nifi/conf/nifi.properties' '/var/lib/nifi/conf/' && chmod 0640 '/var/lib/nifi/conf/nifi.properties')
          test -f '/var/lib/nifi/conf/stateless-logback.xml'                || (cp '${cfg.package}/share/nifi/conf/stateless-logback.xml' '/var/lib/nifi/conf/' && chmod 0640 '/var/lib/nifi/conf/stateless-logback.xml')
          test -f '/var/lib/nifi/conf/stateless.properties'                 || (cp '${cfg.package}/share/nifi/conf/stateless.properties' '/var/lib/nifi/conf/' && chmod 0640 '/var/lib/nifi/conf/stateless.properties')
          test -f '/var/lib/nifi/conf/state-management.xml'                 || (cp '${cfg.package}/share/nifi/conf/state-management.xml' '/var/lib/nifi/conf/' && chmod 0640 '/var/lib/nifi/conf/state-management.xml')
          test -f '/var/lib/nifi/conf/zookeeper.properties'                 || (cp '${cfg.package}/share/nifi/conf/zookeeper.properties' '/var/lib/nifi/conf/' && chmod 0640 '/var/lib/nifi/conf/zookeeper.properties')
          test -d '/var/lib/nifi/docs/html'                                 || (mkdir -p /var/lib/nifi/docs && cp -r '${cfg.package}/share/nifi/docs/html' '/var/lib/nifi/docs/html')
          ${lib.optionalString ((cfg.initUser != null) && (cfg.initPasswordFile != null)) ''
            awk -F'[<|>]' '/property name="Username"/ {if ($3!="") f=1} END{exit !f}' /var/lib/nifi/conf/login-identity-providers.xml || ${cfg.package}/bin/nifi.sh set-single-user-credentials ${cfg.initUser} $(cat ${cfg.initPasswordFile})
          ''}
          ${lib.optionalString (cfg.enableHTTPS == false) ''
            sed -i /var/lib/nifi/conf/nifi.properties \
              -e 's|nifi.remote.input.secure=.*|nifi.remote.input.secure=false|g' \
              -e 's|nifi.web.http.host=.*|nifi.web.http.host=${cfg.listenHost}|g' \
              -e 's|nifi.web.http.port=.*|nifi.web.http.port=${(toString cfg.listenPort)}|g' \
              -e 's|nifi.web.https.host=.*|nifi.web.https.host=|g' \
              -e 's|nifi.web.https.port=.*|nifi.web.https.port=|g' \
              -e 's|nifi.security.keystore=.*|nifi.security.keystore=|g' \
              -e 's|nifi.security.keystoreType=.*|nifi.security.keystoreType=|g' \
              -e 's|nifi.security.truststore=.*|nifi.security.truststore=|g' \
              -e 's|nifi.security.truststoreType=.*|nifi.security.truststoreType=|g' \
              -e '/nifi.security.keystorePasswd/s|^|#|' \
              -e '/nifi.security.keyPasswd/s|^|#|' \
              -e '/nifi.security.truststorePasswd/s|^|#|'
          ''}
          ${lib.optionalString (cfg.enableHTTPS == true) ''
            sed -i /var/lib/nifi/conf/nifi.properties \
              -e 's|nifi.remote.input.secure=.*|nifi.remote.input.secure=true|g' \
              -e 's|nifi.web.http.host=.*|nifi.web.http.host=|g' \
              -e 's|nifi.web.http.port=.*|nifi.web.http.port=|g' \
              -e 's|nifi.web.https.host=.*|nifi.web.https.host=${cfg.listenHost}|g' \
              -e 's|nifi.web.https.port=.*|nifi.web.https.port=${(toString cfg.listenPort)}|g' \
              -e 's|nifi.security.keystore=.*|nifi.security.keystore=./conf/keystore.p12|g' \
              -e 's|nifi.security.keystoreType=.*|nifi.security.keystoreType=PKCS12|g' \
              -e 's|nifi.security.truststore=.*|nifi.security.truststore=./conf/truststore.p12|g' \
              -e 's|nifi.security.truststoreType=.*|nifi.security.truststoreType=PKCS12|g' \
              -e '/nifi.security.keystorePasswd/s|^#\+||' \
              -e '/nifi.security.keyPasswd/s|^#\+||' \
              -e '/nifi.security.truststorePasswd/s|^#\+||'
          ''}
          ${lib.optionalString
            ((cfg.enableHTTPS == true) && (cfg.proxyHost != null) && (cfg.proxyPort != null))
            ''
              sed -i /var/lib/nifi/conf/nifi.properties \
                -e 's|nifi.web.proxy.host=.*|nifi.web.proxy.host=${cfg.proxyHost}:${(toString cfg.proxyPort)}|g'
            ''
          }
          ${lib.optionalString
            ((cfg.enableHTTPS == false) || (cfg.proxyHost == null) && (cfg.proxyPort == null))
            ''
              sed -i /var/lib/nifi/conf/nifi.properties \
                -e 's|nifi.web.proxy.host=.*|nifi.web.proxy.host=|g'
            ''
          }
          ${lib.optionalString ((cfg.initJavaHeapSize != null) && (cfg.maxJavaHeapSize != null)) ''
            sed -i /var/lib/nifi/conf/bootstrap.conf \
              -e 's|java.arg.2=.*|java.arg.2=-Xms${(toString cfg.initJavaHeapSize)}m|g' \
              -e 's|java.arg.3=.*|java.arg.3=-Xmx${(toString cfg.maxJavaHeapSize)}m|g'
          ''}
          ${lib.optionalString ((cfg.initJavaHeapSize == null) && (cfg.maxJavaHeapSize == null)) ''
            sed -i /var/lib/nifi/conf/bootstrap.conf \
              -e 's|java.arg.2=.*|java.arg.2=-Xms512m|g' \
              -e 's|java.arg.3=.*|java.arg.3=-Xmx512m|g'
          ''}
        '';

        ExecStop = "${cfg.package}/bin/nifi.sh stop";
        Group = cfg.group;
        LockPersonality = true;
        # Logs directory and mode
        LogsDirectory = "nifi";
        LogsDirectoryMode = "0750";
        MemoryDenyWriteExecute = false;
        # Security
        NoNewPrivileges = true;
        PIDFile = "/run/nifi/nifi.pid";
        PrivateDevices = true;
        PrivateIPC = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        # Proc filesystem
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        # Sandboxing
        ProtectSystem = "strict";
        # Access write directories
        ReadWritePaths = [ cfg.initPasswordFile ];
        RemoveIPC = true;
        RestrictAddressFamilies = [ "AF_INET AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        # Runtime directory and mode
        RuntimeDirectory = "nifi";
        RuntimeDirectoryMode = "0750";
        # State directory and mode
        StateDirectory = "nifi";
        StateDirectoryMode = "0750";
        # System Call Filtering
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "~@cpu-emulation @debug @keyring @memlock @mount @obsolete @resources @privileged @setuid"
          "@chown"
        ];

        Type = "forking";
        UMask = "0027";
        # User and group
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-nifi" = {
      "/var/lib/nifi/conf".d = {
        inherit (cfg) user group;
        mode = "0750";
      };

      "/var/lib/nifi/lib"."L+" = {
        argument = "${cfg.package}/lib";
      };
    };

    users.groups = lib.optionalAttrs (cfg.group == "nifi") {
      nifi = { };
    };

    users.users = lib.mkMerge [
      (lib.mkIf (cfg.user == "nifi") {
        nifi = {
          group = cfg.group;
          home = cfg.package;
          isSystemUser = true;
        };
      })
      (lib.attrsets.setAttrByPath [ cfg.user "packages" ] [ cfg.package nifiEnv ])
    ];

    warnings = lib.optional (cfg.enableHTTPS == false) ''
      Please do not disable HTTPS mode in production. In this mode, access to the nifi is opened without authentication.
    '';
  };
}
