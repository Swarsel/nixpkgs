{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hqplayerd;
  pkg = pkgs.hqplayerd;
  # XXX: This is hard-coded in the distributed binary, don't try to change it.
  stateDir = "/var/lib/hqplayer";
  configDir = "/etc/hqplayer";
in
{
  options = {
    services.hqplayerd = {
      config = lib.mkOption {
        default = null;

        description = ''
          HQplayer daemon configuration, written to /etc/hqplayer/hqplayerd.xml.

          Refer to share/doc/hqplayerd/readme.txt in the hqplayerd derivation for possible values.
        '';

        type = lib.types.nullOr lib.types.lines;
      };

      enable = lib.mkEnableOption "HQPlayer Embedded";

      auth = {
        password = lib.mkOption {
          default = null;

          description = ''
            Password used for HQPlayer's WebUI.

            Without this you will need to manually create the credentials after
            first start by going to http://your.ip/8088/auth
          '';

          type = lib.types.nullOr lib.types.str;
        };

        username = lib.mkOption {
          default = null;

          description = ''
            Username used for HQPlayer's WebUI.

            Without this you will need to manually create the credentials after
            first start by going to http://your.ip/8088/auth
          '';

          type = lib.types.nullOr lib.types.str;
        };
      };

      licenseFile = lib.mkOption {
        default = null;

        description = ''
          Path to the HQPlayer license key file.

          Without this, the service will run in trial mode and restart every 30
          minutes.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Opens ports needed for the WebUI and controller API.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          (cfg.auth.username != null -> cfg.auth.password != null)
          && (cfg.auth.password != null -> cfg.auth.username != null);

        message = "You must set either both services.hqplayer.auth.username and password, or neither.";
      }
    ];

    environment = {
      etc = {
        "hqplayer/hqplayerd.xml" = lib.mkIf (cfg.config != null) {
          source = pkgs.writeText "hqplayerd.xml" cfg.config;
        };

        "hqplayer/hqplayerd4-key.xml" = lib.mkIf (cfg.licenseFile != null) { source = cfg.licenseFile; };
      };

      systemPackages = [ pkg ];
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        8088
        4321
      ];
    };

    systemd = {
      packages = [ pkg ];

      services.hqplayerd = {
        after = [ "systemd-tmpfiles-setup.service" ];
        environment.HOME = "${stateDir}/home";

        preStart = ''
          cp -r "${pkg}/var/lib/hqplayer/web" "${stateDir}"
          chmod -R u+wX "${stateDir}/web"

          if [ ! -f "${configDir}/hqplayerd.xml" ]; then
            echo "creating initial config file"
            install -m 0644 "${pkg}/etc/hqplayer/hqplayerd.xml" "${configDir}/hqplayerd.xml"
          fi
        ''
        + lib.optionalString (cfg.auth.username != null && cfg.auth.password != null) ''
          ${pkg}/bin/hqplayerd -s ${cfg.auth.username} ${cfg.auth.password}
        '';

        restartTriggers = lib.optionals (cfg.config != null) [
          config.environment.etc."hqplayer/hqplayerd.xml".source
        ];

        unitConfig.ConditionPathExists = [
          configDir
          stateDir
        ];

        wantedBy = [ "multi-user.target" ];
      };

      tmpfiles.rules = [
        "d ${configDir}      0755 hqplayer hqplayer - -"
        "d ${stateDir}       0755 hqplayer hqplayer - -"
        "d ${stateDir}/home  0755 hqplayer hqplayer - -"
      ];
    };

    users.groups = {
      hqplayer.gid = config.ids.gids.hqplayer;
    };

    users.users = {
      hqplayer = {
        description = "hqplayer daemon user";

        extraGroups = [
          "audio"
          "video"
        ];

        group = "hqplayer";
        uid = config.ids.uids.hqplayer;
      };
    };
  };
}
