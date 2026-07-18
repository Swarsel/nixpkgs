{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.sogo;

  preStart = pkgs.writeShellScriptBin "sogo-prestart" ''
    ${
      if (cfg.configReplaces != { }) then
        ''
          # Insert secrets
          ${concatStringsSep "\n" (
            mapAttrsToList (k: v: ''export ${k}="$(cat "${v}" | tr -d '\n')"'') cfg.configReplaces
          )}

          ${pkgs.perl}/bin/perl -p ${
            concatStringsSep " " (
              mapAttrsToList (k: v: ''-e 's/${k}/''${ENV{"${k}"}}/g;' '') cfg.configReplaces
            )
          } /etc/sogo/sogo.conf.raw | install -m 640 -o sogo -g sogo /dev/stdin /etc/sogo/sogo.conf
        ''
      else
        ''
          install -m 640 -o sogo -g sogo /etc/sogo/sogo.conf.raw /etc/sogo/sogo.conf
        ''
    }
  '';

in
{
  options.services.sogo = with types; {
    enable = mkEnableOption "SOGo groupware";

    configReplaces = mkOption {
      default = { };

      description = ''
        Replacement-filepath mapping for sogo.conf.
        Every key is replaced with the contents of the file specified as value.

        In the example, every occurrence of LDAP_BINDPW will be replaced with the text of the
        specified file.
      '';

      example = {
        LDAP_BINDPW = "/var/lib/secrets/sogo/ldappw";
      };

      type = attrsOf str;
    };

    ealarmsCredFile = mkOption {
      default = null;
      description = "Optional path to a credentials file for email alarms";
      type = nullOr str;
    };

    extraConfig = mkOption {
      default = "";
      description = "Extra sogo.conf configuration lines";
      type = lines;
    };

    language = mkOption {
      default = "English";
      description = "Language of SOGo";
      type = str;
    };

    timezone = mkOption {
      description = "Timezone of your SOGo instance";
      example = "America/Montreal";
      type = str;
    };

    vhostName = mkOption {
      default = "sogo";
      description = "Name of the nginx vhost";
      type = str;
    };
  };

  config = mkIf cfg.enable {
    environment.etc."sogo/sogo.conf.raw".text = ''
      {
        // Mandatory parameters
        SOGoTimeZone = "${cfg.timezone}";
        SOGoLanguage = "${cfg.language}";
        // Paths
        WOSendMail = "/run/wrappers/bin/sendmail";
        SOGoMailSpoolPath = "/var/lib/sogo/spool";
        // Enable CSRF protection
        SOGoXSRFValidationEnabled = YES;
        // Remove dates from log (jornald does that)
        NGLogDefaultLogEventFormatterClass = "NGLogEventFormatter";
        // Extra config
        ${cfg.extraConfig}
      }
    '';

    environment.systemPackages = [ pkgs.sogo ];

    # nginx vhost
    services.nginx.virtualHosts."${cfg.vhostName}" = {
      locations."/".extraConfig = ''
        rewrite ^ https://$server_name/SOGo;
        allow all;
      '';

      locations."/SOGo.woa/WebServerResources/".extraConfig = ''
        alias ${pkgs.sogo}/lib/GNUstep/SOGo/WebServerResources/;
        allow all;
      '';

      locations."/SOGo/WebServerResources/".extraConfig = ''
        alias ${pkgs.sogo}/lib/GNUstep/SOGo/WebServerResources/;
        allow all;
      '';

      # For iOS 7
      locations."/principals/".extraConfig = ''
        rewrite ^ https://$server_name/SOGo/dav;
        allow all;
      '';

      locations."^~/SOGo".extraConfig = ''
        proxy_pass http://127.0.0.1:20000;
        proxy_redirect http://127.0.0.1:20000 default;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_set_header x-webobjects-server-protocol HTTP/1.0;
        proxy_set_header x-webobjects-remote-host 127.0.0.1;
        proxy_set_header x-webobjects-server-port $server_port;
        proxy_set_header x-webobjects-server-name $server_name;
        proxy_set_header x-webobjects-server-url $scheme://$host;
        proxy_connect_timeout 90;
        proxy_send_timeout 90;
        proxy_read_timeout 90;
        proxy_buffer_size 64k;
        proxy_buffers 8 64k;
        proxy_busy_buffers_size 64k;
        proxy_temp_file_write_size 64k;
        client_max_body_size 50m;
        client_body_buffer_size 128k;
        break;
      '';

      locations."~ ^/SOGo/so/ControlPanel/Products/([^/]*)/Resources/(.*)$".extraConfig = ''
        alias ${pkgs.sogo}/lib/GNUstep/SOGo/$1.SOGo/Resources/$2;
      '';

      locations."~ ^/SOGo/so/ControlPanel/Products/[^/]*UI/Resources/.*\\.(jpg|png|gif|css|js)$".extraConfig =
        ''
          alias ${pkgs.sogo}/lib/GNUstep/SOGo/$1.SOGo/Resources/$2;
        '';
    };

    systemd.services.sogo = {
      after = [
        "postgresql.target"
        "mysql.service"
        "memcached.service"
        "openldap.service"
        "dovecot2.service"
      ];

      description = "SOGo groupware";
      environment.LDAPTLS_CACERT = config.security.pki.caBundle;
      restartTriggers = [ config.environment.etc."sogo/sogo.conf.raw".source ];

      serviceConfig = {
        CapabilityBoundingSet = "";
        ExecStart = "${pkgs.sogo}/bin/sogod -WOLogFile - -WOPidFile /run/sogo/sogo.pid";
        ExecStartPre = "+" + preStart + "/bin/sogo-prestart";
        Group = "sogo";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
        RestrictRealtime = true;
        RuntimeDirectory = "sogo";
        StateDirectory = "sogo/spool";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@basic-io @file-system @network-io @system-service @timer";
        Type = "forking";
        User = "sogo";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.sogo-ealarms = {
      after = [
        "postgresql.target"
        "mysqld.service"
        "memcached.service"
        "openldap.service"
        "dovecot2.service"
        "sogo.service"
      ];

      description = "SOGo email alarms";
      restartTriggers = [ config.environment.etc."sogo/sogo.conf.raw".source ];

      serviceConfig = {
        CapabilityBoundingSet = "";

        ExecStart = "${pkgs.sogo}/bin/sogo-ealarms-notify${
          optionalString (cfg.ealarmsCredFile != null) " -p ${cfg.ealarmsCredFile}"
        }";

        Group = "sogo";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
        RestrictRealtime = true;
        StateDirectory = "sogo/spool";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@basic-io @file-system @network-io @system-service";
        Type = "oneshot";
        User = "sogo";
      };

      startAt = [ "minutely" ];
    };

    systemd.services.sogo-tmpwatch = {
      description = "SOGo tmpwatch";

      script = ''
        SOGOSPOOL=/var/lib/sogo/spool

        find "$SOGOSPOOL" -type f -user sogo -atime +23 -delete > /dev/null
        find "$SOGOSPOOL" -mindepth 1 -type d -user sogo -empty -delete > /dev/null
      '';

      serviceConfig = {
        CapabilityBoundingSet = "";
        Group = "sogo";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateNetwork = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = "";
        RestrictRealtime = true;
        StateDirectory = "sogo/spool";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@basic-io @file-system @system-service";
        Type = "oneshot";
        User = "sogo";
      };

      startAt = [ "hourly" ];
    };

    # User and group
    users.groups.sogo = { };

    users.users.sogo = {
      description = "SOGo service user";
      group = "sogo";
      isSystemUser = true;
    };
  };
}
