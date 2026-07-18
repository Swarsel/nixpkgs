{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ntfy-sh;

  settingsFormat = pkgs.formats.yaml { };
in

{
  options.services.ntfy-sh = {
    enable = lib.mkEnableOption "[ntfy-sh](https://ntfy.sh), a push notification service";
    package = lib.mkPackageOption pkgs "ntfy-sh" { };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        Path to a file containing extra ntfy environment variables in the systemd `EnvironmentFile`
        format. Refer to the [documentation](https://docs.ntfy.sh/config/) for config options.

        This can be used to pass secrets such as creating declarative users or token without putting them in the Nix store.
      '';

      example = "/run/secrets/ntfy";
      type = lib.types.nullOr lib.types.path;
    };

    group = lib.mkOption {
      default = "ntfy-sh";
      description = "Primary group of ntfy-sh user.";
      type = lib.types.str;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for ntfy.sh, supported values are [here](https://ntfy.sh/docs/config/#config-options).
      '';

      example = lib.literalExpression ''
        {
          listen-http = ":8080";
        }
      '';

      type = lib.types.submodule {
        options = {
          base-url = lib.mkOption {
            description = ''
              Public facing base URL of the service

              This setting is required for any of the following features:
              - attachments (to return a download URL)
              - e-mail sending (for the topic URL in the email footer)
              - iOS push notifications for self-hosted servers
                (to calculate the Firebase poll_request topic)
              - Matrix Push Gateway (to validate that the pushkey is correct)
            '';

            example = "https://ntfy.example";
            type = lib.types.str;
          };
        };

        freeformType = settingsFormat.type;
      };
    };

    user = lib.mkOption {
      default = "ntfy-sh";
      description = "User the ntfy-sh server runs under.";
      type = lib.types.str;
    };
  };

  config =
    let
      configuration = settingsFormat.generate "server.yml" cfg.settings;
    in
    lib.mkIf cfg.enable {
      # to configure access control via the cli
      environment = {
        etc."ntfy/server.yml".source = configuration;
        systemPackages = [ cfg.package ];
      };

      services.ntfy-sh.settings = {
        attachment-cache-dir = lib.mkDefault "/var/lib/ntfy-sh/attachments";
        auth-file = lib.mkDefault "/var/lib/ntfy-sh/user.db";
        cache-file = lib.mkDefault "/var/lib/ntfy-sh/cache-file.db";
        listen-http = lib.mkDefault "127.0.0.1:2586";
      };

      systemd.services.ntfy-sh = {
        after = [ "network.target" ];
        description = "Push notifications server";

        serviceConfig = {
          AmbientCapabilities = "CAP_NET_BIND_SERVICE";
          CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
          DynamicUser = true;
          EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
          ExecStart = "${cfg.package}/bin/ntfy serve -c ${configuration}";
          # Upstream Recommendation
          LimitNOFILE = 20500;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "full";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = "ntfy-sh";
          StateDirectory = "ntfy-sh";
          User = cfg.user;
        };

        wantedBy = [ "multi-user.target" ];
      };

      users.groups = lib.optionalAttrs (cfg.group == "ntfy-sh") {
        ntfy-sh = { };
      };

      users.users = lib.optionalAttrs (cfg.user == "ntfy-sh") {
        ntfy-sh = {
          group = cfg.group;
          isSystemUser = true;
        };
      };
    };
}
