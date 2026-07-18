{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.youtrack;
in
{
  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "youtrack" "baseUrl" ]
      [ "services" "youtrack" "environmentalParameters" "base-url" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "youtrack" "port" ]
      [ "services" "youtrack" "environmentalParameters" "listen-port" ]
    )
    (lib.mkRemovedOptionModule [
      "services"
      "youtrack"
      "maxMemory"
    ] "Please instead use `services.youtrack.generalParameters`.")
    (lib.mkRemovedOptionModule [
      "services"
      "youtrack"
      "maxMetaspaceSize"
    ] "Please instead use `services.youtrack.generalParameters`.")
    (lib.mkRemovedOptionModule [
      "services"
      "youtrack"
      "extraParams"
    ] "Please migrate to `services.youtrack.generalParameters`.")
    (lib.mkRemovedOptionModule [
      "services"
      "youtrack"
      "jvmOpts"
    ] "Please migrate to `services.youtrack.generalParameters`.")
  ];

  options.services.youtrack = {
    enable = lib.mkEnableOption "YouTrack service";
    package = lib.mkPackageOption pkgs "youtrack" { };

    address = lib.mkOption {
      default = "127.0.0.1";

      description = ''
        The interface youtrack will listen on.
      '';

      type = lib.types.str;
    };

    autoUpgrade = lib.mkOption {
      default = true;
      description = "Whether YouTrack should auto upgrade it without showing the upgrade dialog.";
      type = lib.types.bool;
    };

    environmentalParameters = lib.mkOption {
      default = { };

      description = ''
        Environmental configuration parameters, set imperatively. The values doesn't get removed, when removed in Nix.
        See <https://www.jetbrains.com/help/youtrack/server/2023.3/youtrack-java-start-parameters.html#environmental-parameters>
        for more information.
      '';

      example = lib.literalExpression ''
        {
          secure-mode = "tls";
        }
      '';

      type = lib.types.submodule {
        options = {
          listen-address = lib.mkOption {
            default = "0.0.0.0";
            description = "The interface YouTrack will listen on.";
            type = lib.types.str;
          };

          listen-port = lib.mkOption {
            default = 8080;
            description = "The port YouTrack will listen on.";
            type = lib.types.port;
          };
        };

        freeformType =
          with lib.types;
          attrsOf (oneOf [
            int
            str
            port
          ]);
      };
    };

    generalParameters = lib.mkOption {
      default = [ ];

      description = ''
        General configuration parameters and other JVM options.
        See <https://www.jetbrains.com/help/youtrack/server/2023.3/youtrack-java-start-parameters.html#general-parameters>
        for more information.
      '';

      example = lib.literalExpression ''
        [
          "-Djetbrains.youtrack.admin.restore=true"
          "-Xmx1024m"
        ];
      '';

      type = with lib.types; listOf str;
    };

    statePath = lib.mkOption {
      default = "/var/lib/youtrack";

      description = ''
        Path were the YouTrack state is stored.
        To this path the base version (e.g. 2023_1) of the used package will be appended.
      '';

      type = lib.types.path;
    };

    virtualHost = lib.mkOption {
      default = null;

      description = ''
        Name of the nginx virtual host to use and setup.
        If null, do not setup anything.
      '';

      type = lib.types.nullOr lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = lib.mkIf (cfg.virtualHost != null) {
      upstreams.youtrack.servers."${cfg.address}:${toString cfg.environmentalParameters.listen-port}" =
        { };

      virtualHosts.${cfg.virtualHost}.locations = {
        "/" = {
          extraConfig = ''
            client_max_body_size 10m;
            proxy_http_version 1.1;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';

          proxyPass = "http://youtrack";
        };

        "/api/eventSourceBus" = {
          extraConfig = ''
            proxy_cache off;
            proxy_buffering off;
            proxy_read_timeout 86400s;
            proxy_send_timeout 86400s;
            proxy_set_header Connection "";
            chunked_transfer_encoding off;
            client_max_body_size 10m;
            proxy_http_version 1.1;
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';

          proxyPass = "http://youtrack";
        };
      };
    };

    services.youtrack.generalParameters = [
      "-Ddisable.configuration.wizard.on.upgrade=${lib.boolToString cfg.autoUpgrade}"
    ];

    systemd.services.youtrack =
      let
        jvmoptions = pkgs.writeTextFile {
          name = "youtrack.jvmoptions";
          text = (lib.concatStringsSep "\n" cfg.generalParameters);
        };

        package = cfg.package.override {
          statePath = cfg.statePath;
        };
      in
      {
        after = [ "network.target" ];
        path = with pkgs; [ unixtools.hostname ];

        preStart = ''
          # This detects old (i.e. <= 2022.3) installations that were not migrated yet
          # and migrates them to the new state directory style
          if [[ -d ${cfg.statePath}/teamsysdata ]] && [[ ! -d ${cfg.statePath}/2022_3 ]]
          then
            mkdir -p ${cfg.statePath}/2022_3
            mv ${cfg.statePath}/teamsysdata ${cfg.statePath}/2022_3
            mv ${cfg.statePath}/.youtrack ${cfg.statePath}/2022_3
          fi
          mkdir -p ${cfg.statePath}/{backups,conf,data,logs,temp}
          ${pkgs.coreutils}/bin/ln -fs ${jvmoptions} ${cfg.statePath}/conf/youtrack.jvmoptions
          ${package}/bin/youtrack configure ${
            lib.concatStringsSep " " (
              lib.mapAttrsToList (name: value: "--${name}=${toString value}") cfg.environmentalParameters
            )
          }
        '';

        serviceConfig = lib.mkMerge [
          {
            ExecStart = "${package}/bin/youtrack run";
            Group = "youtrack";
            Restart = "on-failure";
            Type = "simple";
            User = "youtrack";
          }
          (lib.mkIf (cfg.statePath == "/var/lib/youtrack") {
            StateDirectory = "youtrack";
          })
        ];

        wantedBy = [ "multi-user.target" ];
      };

    users.groups.youtrack = { };

    users.users.youtrack = {
      createHome = true;
      description = "Youtrack service user";
      group = "youtrack";
      home = cfg.statePath;
      isSystemUser = true;
    };
  };

  meta.doc = ./youtrack.md;
  meta.maintainers = [ lib.maintainers.leona ];
}
