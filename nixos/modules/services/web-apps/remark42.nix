{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.remark42;
  siteList = lib.concatStringsSep "," cfg.sites;
in
{
  options.services.remark42 = {
    enable = lib.mkEnableOption "Remark42 commenting server";
    package = lib.mkPackageOption pkgs "remark42" { };

    dataDir = lib.mkOption {
      default = "/var/lib/remark42";

      description = ''
        Working directory for Remark42. Data files are stored here and
        automatic backups will be created in this directory by default.
      '';

      type = lib.types.path;
    };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        Optional environment file in systemd `EnvironmentFile=` format.
        Use this for secrets to avoid storing them in the Nix store.
      '';

      example = "/run/secrets/remark42.env";
      type = lib.types.nullOr lib.types.path;
    };

    listenAddress = lib.mkOption {
      default = "127.0.0.1";
      description = "Bind address (`REMARK_ADDRESS`).";
      example = "0.0.0.0";
      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether to open the firewall for `port`.";
      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 8080;
      description = "Listen port (`REMARK_PORT`).";
      type = lib.types.port;
    };

    remarkUrl = lib.mkOption {
      description = ''
        Public URL of this Remark42 instance. This is passed to the backend as
        `REMARK_URL` and should match the frontend embed config `host`.
      '';

      example = "https://comments.example.com";
      type = lib.types.str;
    };

    settings = lib.mkOption {
      default = { };
      description = "Extra environment variables passed to Remark42.";

      example = {
        AUTH_ANON = "true";
      };

      type = lib.types.attrsOf lib.types.str;
    };

    sites = lib.mkOption {
      default = [ "remark" ];

      description = ''
        Site IDs served by this instance (passed as `SITE`, comma-separated).
        The frontend embed config `site_id` must match one of these values.
      '';

      example = [
        "blog"
        "docs"
      ];

      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.sites != [ ];
        message = "services.remark42.sites must contain at least one site ID.";
      }
      {
        assertion = cfg.environmentFile != null || (cfg.settings ? SECRET);

        message = ''
          Remark42 requires SECRET.
          Provide it via services.remark42.environmentFile (recommended),
          or via services.remark42.settings.SECRET (not recommended).
        '';
      }
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.remark42 = {
      after = [ "network.target" ];
      description = "Remark42 commenting server";

      environment = cfg.settings // {
        REMARK_ADDRESS = cfg.listenAddress;
        REMARK_PORT = toString cfg.port;
        REMARK_URL = cfg.remarkUrl;
        SITE = siteList;
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/remark42 server";
        Group = "remark42";
        Restart = "on-failure";
        RestartSec = "2s";
        Type = "simple";
        User = "remark42";
        WorkingDirectory = cfg.dataDir;
      }
      // lib.optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.remark42 = { };

    users.users.remark42 = {
      createHome = true;
      description = "Remark42 service user";
      group = "remark42";
      home = cfg.dataDir;
      isSystemUser = true;
    };
  };
}
