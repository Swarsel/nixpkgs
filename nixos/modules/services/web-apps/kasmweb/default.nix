{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.kasmweb;
in
{
  options.services.kasmweb = {
    enable = lib.mkEnableOption "kasmweb";

    datastorePath = lib.mkOption {
      default = "/var/lib/kasmweb";

      description = ''
        The directory used to store all data for kasmweb.
      '';

      type = lib.types.str;
    };

    defaultAdminPassword = lib.mkOption {
      default = "kasmweb";

      description = ''
        default admin password to use.
      '';

      type = lib.types.str;
    };

    defaultGuacToken = lib.mkOption {
      default = "kasmweb";

      description = ''
        default guac token to use.
      '';

      type = lib.types.str;
    };

    defaultManagerToken = lib.mkOption {
      default = "kasmweb";

      description = ''
        default manager token to use.
      '';

      type = lib.types.str;
    };

    defaultRegistrationToken = lib.mkOption {
      default = "kasmweb";

      description = ''
        default registration token to use.
      '';

      type = lib.types.str;
    };

    defaultUserPassword = lib.mkOption {
      default = "kasmweb";

      description = ''
        default user password to use.
      '';

      type = lib.types.str;
    };

    listenAddress = lib.mkOption {
      default = "0.0.0.0";

      description = ''
        The address on which kasmweb should listen.
      '';

      type = lib.types.str;
    };

    listenPort = lib.mkOption {
      default = 443;

      description = ''
        The port on which kasmweb should listen.
      '';

      type = lib.types.port;
    };

    networkSubnet = lib.mkOption {
      default = "172.20.0.0/16";

      description = ''
        The network subnet to use for the containers.
      '';

      type = lib.types.str;
    };

    postgres = {
      password = lib.mkOption {
        default = "kasmweb";

        description = ''
          password to use for the postgres database.
        '';

        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "kasmweb";

        description = ''
          Username to use for the postgres database.
        '';

        type = lib.types.str;
      };
    };

    redisPassword = lib.mkOption {
      default = "kasmweb";

      description = ''
        password to use for the redis cache.
      '';

      type = lib.types.str;
    };

    sslCertificate = lib.mkOption {
      default = null;

      description = ''
        The SSL certificate to be used for kasmweb.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    sslCertificateKey = lib.mkOption {
      default = null;

      description = ''
        The SSL certificate's key to be used for kasmweb. Make sure to specify
        this as a string and not a literal path, so that it is not accidentally
        included in your nixstore.
      '';

      type = lib.types.nullOr lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services = {
      "init-kasmweb" = {
        after = [ "network-online.target" ];

        serviceConfig = {
          ExecStart = pkgs.replaceVarsWith {
            isExecutable = true;

            replacements = {
              inherit (cfg)
                datastorePath
                sslCertificate
                sslCertificateKey
                redisPassword
                networkSubnet
                defaultUserPassword
                defaultAdminPassword
                defaultManagerToken
                defaultRegistrationToken
                defaultGuacToken
                ;

              binPath = lib.makeBinPath [
                pkgs.docker
                pkgs.openssl
                pkgs.gnused
                pkgs.yq-go
              ];

              kasmweb = pkgs.kasmweb;
              postgresPassword = "postgres";
              postgresUser = "postgres";
              runtimeShell = pkgs.runtimeShell;
            };

            src = ./initialize_kasmweb.sh;
          };

          TimeoutStartSec = 300;
          Type = "oneshot";
        };

        wantedBy = [
          "docker-kasm_db.service"
          "podman-kasm_db.service"
        ];

        wants = [ "network-online.target" ];
      };
    };

    virtualisation = {
      oci-containers.backend = "docker";

      oci-containers.containers = {
        kasm_agent = {
          autoStart = false;
          dependsOn = [ "kasm_manager" ];

          extraOptions = [
            "--network=kasm_default_network"
            "--userns=host"
            "--read-only"
          ];

          image = "kasmweb/agent:${pkgs.kasmweb.version}";
          user = "root:root";

          volumes = [
            "${cfg.datastorePath}/:/opt/kasm/current/"
            "/var/run/docker.sock:/var/run/docker.sock"
            "${pkgs.docker}/bin/docker:/usr/bin/docker"
            "${cfg.datastorePath}/conf/nginx:/etc/nginx/conf.d"
          ];
        };

        kasm_api = {
          autoStart = false;
          dependsOn = [ "kasm_db_init" ];

          extraOptions = [
            "--network=kasm_default_network"
            "--userns=host"
          ];

          image = "kasmweb/api:${pkgs.kasmweb.version}";
          user = "root:root";

          volumes = [
            "${cfg.datastorePath}/:/opt/kasm/current/"
            "kasmweb_api_data:/tmp"
          ];
        };

        kasm_db = {
          autoStart = true;

          environment = {
            POSTGRES_DB = "kasm";
            POSTGRES_PASSWORD = "postgres";
            POSTGRES_USER = "postgres";
          };

          extraOptions = [ "--network=kasm_default_network" ];
          image = "postgres:16-alpine";

          volumes = [
            "${cfg.datastorePath}/conf/database/data.sql:/docker-entrypoint-initdb.d/data.sql"
            "${cfg.datastorePath}/conf/database/:/tmp/"
            "kasmweb_db:/var/lib/postgresql/data"
          ];
        };

        kasm_db_init = {
          autoStart = true;
          cmd = [ "/opt/kasm/current/init_seeds.sh" ];
          dependsOn = [ "kasm_db" ];
          entrypoint = "/bin/bash";

          extraOptions = [
            "--network=kasm_default_network"
            "--userns=host"
          ];

          image = "kasmweb/api:${pkgs.kasmweb.version}";
          user = "root:root";

          volumes = [
            "${cfg.datastorePath}/:/opt/kasm/current/"
            "kasmweb_api_data:/tmp"
          ];
        };

        kasm_guac = {
          autoStart = false;

          dependsOn = [
            "kasm_db"
            "kasm_redis"
          ];

          extraOptions = [
            "--network=kasm_default_network"
            "--userns=host"
            "--read-only"
          ];

          image = "kasmweb/kasm-guac:${pkgs.kasmweb.version}";
          user = "root:root";

          volumes = [
            "${cfg.datastorePath}/:/opt/kasm/current/"
          ];
        };

        kasm_manager = {
          autoStart = false;

          dependsOn = [
            "kasm_db_init"
            "kasm_db"
            "kasm_api"
          ];

          extraOptions = [
            "--network=kasm_default_network"
            "--userns=host"
            "--read-only"
          ];

          image = "kasmweb/manager:${pkgs.kasmweb.version}";
          user = "root:root";

          volumes = [
            "${cfg.datastorePath}/:/opt/kasm/current/"
          ];
        };

        kasm_proxy = {
          autoStart = false;

          dependsOn = [
            "kasm_manager"
            "kasm_api"
            "kasm_agent"
            "kasm_share"
            "kasm_guac"
          ];

          extraOptions = [
            "--network=kasm_default_network"
            "--userns=host"
            "--network-alias=proxy"
          ];

          image = "kasmweb/nginx:latest";
          ports = [ "${cfg.listenAddress}:${toString cfg.listenPort}:443" ];
          user = "root:root";

          volumes = [
            "${cfg.datastorePath}/conf/nginx:/etc/nginx/conf.d:ro"
            "${cfg.datastorePath}/certs/kasm_nginx.key:/etc/ssl/private/kasm_nginx.key"
            "${cfg.datastorePath}/certs/kasm_nginx.crt:/etc/ssl/certs/kasm_nginx.crt"
            "${cfg.datastorePath}/www:/srv/www:ro"
            "${cfg.datastorePath}/log/nginx:/var/log/external/nginx"
            "${cfg.datastorePath}/log/logrotate:/var/log/external/logrotate"
          ];
        };

        kasm_redis = {
          autoStart = true;

          cmd = [
            "-c"
            "redis-server --requirepass ${cfg.redisPassword}"
          ];

          entrypoint = "/bin/sh";

          extraOptions = [
            "--network=kasm_default_network"
            "--userns=host"
          ];

          image = "redis:5-alpine";
        };

        kasm_share = {
          autoStart = false;

          dependsOn = [
            "kasm_db_init"
            "kasm_db"
            "kasm_redis"
          ];

          extraOptions = [
            "--network=kasm_default_network"
            "--userns=host"
            "--read-only"
          ];

          image = "kasmweb/share:${pkgs.kasmweb.version}";
          user = "root:root";

          volumes = [
            "${cfg.datastorePath}/:/opt/kasm/current/"
          ];
        };
      };
    };
  };
}
