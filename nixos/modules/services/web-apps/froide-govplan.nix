{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.froide-govplan;
  pythonFmt = pkgs.formats.pythonVars { };
  settingsFile = pythonFmt.generate "extra_settings.py" cfg.settings;

  pkg = cfg.package.overridePythonAttrs (old: {
    postInstall = old.postInstall + ''
      ln -s ${settingsFile} $out/${pkg.python.sitePackages}/froide_govplan/project/extra_settings.py
    '';
  });

  froide-govplan = pkgs.writeShellApplication {
    name = "froide-govplan";
    runtimeInputs = [ pkgs.coreutils ];

    text = ''
      SUDO="exec"
      if [[ "$USER" != govplan ]]; then
        SUDO="exec /run/wrappers/bin/sudo -u govplan"
      fi
      $SUDO env ${lib.getExe pkg} "$@"
    '';
  };

  # Service hardening
  defaultServiceConfig = {
    CacheDirectory = "froide-govplan";
    CapabilityBoundingSet = "";
    # ProtectClock adds DeviceAllow=char-rtc r
    DeviceAllow = "";
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateMounts = true;
    PrivateTmp = true;
    PrivateUsers = true;
    ProcSubset = "pid";
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProtectSystem = "strict";
    # Secure the services
    ReadWritePaths = [ cfg.dataDir ];

    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
    ];

    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";

    SystemCallFilter = [
      "@system-service"
      "~@privileged @setuid @keyring"
    ];

    UMask = "0066";
  };

in
{
  options.services.froide-govplan = {

    enable = lib.mkEnableOption "Gouvernment planer web app Govplan";
    package = lib.mkPackageOption pkgs "froide-govplan" { };

    dataDir = lib.mkOption {
      default = "/var/lib/froide-govplan";
      description = "Directory to store the Froide-Govplan server data.";
      type = lib.types.str;
    };

    hostName = lib.mkOption {
      default = "localhost";
      description = "FQDN for the froide-govplan instance.";
      type = lib.types.str;
    };

    secretKeyFile = lib.mkOption {
      default = null;

      description = ''
        Path to a file containing the secret key.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration options to set in `extra_settings.py`.
      '';

      type = lib.types.submodule {
        options = {
          ALLOWED_HOSTS = lib.mkOption {
            default = [ "*" ];

            description = ''
              A list of valid fully-qualified domain names (FQDNs) and/or IP
              addresses that can be used to reach the Froide-Govplan service.
            '';

            type = with lib.types; listOf str;
          };
        };

        freeformType = pythonFmt.type;
      };
    };

  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ froide-govplan ];

    services.froide-govplan = {
      settings = {
        DATABASES.default = {
          ENGINE = "django.contrib.gis.db.backends.postgis";
          HOST = "/run/postgresql";
          NAME = "govplan";
          USER = "govplan";
        };

        DEBUG = false;
        STATIC_ROOT = "${cfg.dataDir}/static";
      };
    };

    services.nginx = {
      enable = lib.mkDefault true;
      proxyTimeout = lib.mkDefault "120s";

      virtualHosts."${cfg.hostName}".locations = {
        "/".extraConfig = "proxy_pass http://unix:/run/froide-govplan/froide-govplan.socket;";
        "/static/".alias = "${cfg.dataDir}/static/";
      };
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "govplan" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "govplan";
        }
      ];

      extensions = ps: with ps; [ postgis ];
    };

    systemd = {
      services = {

        froide-govplan = {
          after = [
            "postgresql.target"
            "network.target"
            "systemd-tmpfiles-setup.service"
          ];

          description = "Gouvernment planer Govplan";

          environment = {
            GDAL_LIBRARY_PATH = "${pkgs.gdal}/lib/libgdal.so";
            GEOS_LIBRARY_PATH = "${pkgs.geos}/lib/libgeos_c.so";
            PYTHONPATH = "${pkg.pythonPath}:${pkg}/${pkg.python.sitePackages}";
          }
          // lib.optionalAttrs (cfg.secretKeyFile != null) {
            SECRET_KEY_FILE = cfg.secretKeyFile;
          };

          preStart = ''
            # Auto-migrate on first run or if the package has changed
            versionFile="${cfg.dataDir}/src-version"
            version=$(cat "$versionFile" 2>/dev/null || echo 0)

            if [[ $version != ${pkg.version} ]]; then
              ${lib.getExe pkg} migrate --no-input
              ${lib.getExe pkg} collectstatic --no-input --clear
              echo ${pkg.version} > "$versionFile"
            fi
          '';

          script = ''
            ${pkg.python.pkgs.uvicorn}/bin/uvicorn --uds /run/froide-govplan/froide-govplan.socket \
              --app-dir ${pkg}/${pkg.python.sitePackages}/froide_govplan \
              project.asgi:application
          '';

          serviceConfig = defaultServiceConfig // {
            Group = "govplan";
            StateDirectory = lib.mkIf (cfg.dataDir == "/var/lib/froide-govplan") "froide-govplan";
            TimeoutStartSec = "5m";
            User = "govplan";
            WorkingDirectory = cfg.dataDir;
          };

          wantedBy = [ "multi-user.target" ];
        };

        postgresql-setup.serviceConfig.ExecStartPost =
          let
            sqlFile = pkgs.writeText "froide-govplan-postgis-setup.sql" ''
              CREATE EXTENSION IF NOT EXISTS postgis;
            '';
          in
          [
            ''
              ${lib.getExe' config.services.postgresql.package "psql"} -d govplan -f "${sqlFile}"
            ''
          ];
      };

    };

    systemd.tmpfiles.rules = [ "d /run/froide-govplan - govplan govplan - -" ];
    users.groups.govplan = { };

    users.users.govplan = {
      group = "govplan";
      home = "${cfg.dataDir}";
      isSystemUser = true;
    };

  };

  meta.maintainers = with lib.maintainers; [ onny ];

}
