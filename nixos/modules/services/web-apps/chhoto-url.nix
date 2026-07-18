{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.chhoto-url;

  environment = lib.mapAttrs (
    _: value:
    if value == true then
      "True"
    else if value == false then
      "False"
    else
      toString value
  ) cfg.settings;
in

{
  options.services.chhoto-url = {
    enable = lib.mkEnableOption "Chhoto URL";
    package = lib.mkPackageOption pkgs "chhoto-url" { };

    environmentFiles = lib.mkOption {
      default = [ ];

      description = ''
        Files to load environment variables from in addition to [](#opt-services.chhoto-url.settings).
        This is useful to avoid putting secrets into the nix store.
        See <https://github.com/SinTan1729/chhoto-url/blob/main/docs/INSTALLATION.md#configuration-options> for a list of options.
      '';

      example = [ "/run/secrets/chhoto-url.env" ];
      type = lib.types.listOf lib.types.path;
    };

    settings = lib.mkOption {
      description = ''
        Configuration of Chhoto URL.
        See <https://github.com/SinTan1729/chhoto-url/blob/main/docs/INSTALLATION.md#configuration-options> for a list of options.
      '';

      example = {
        port = 4567;
      };

      type = lib.types.submodule {
        options = {
          allow_capital_letters = lib.mkOption {
            default = false;
            description = "Whether to allow capital letters in slugs.";
            type = lib.types.bool;
          };

          cache_control_header = lib.mkOption {
            default = null;
            description = "The Cache-Control header to send.";
            example = "no-cache, private";
            type = lib.types.nullOr lib.types.str;
          };

          custom_landing_directory = lib.mkOption {
            default = null;
            description = "The path of a directory which contains a custom landing page.";
            type = lib.types.nullOr lib.types.path;
          };

          db_url = lib.mkOption {
            default = "/var/lib/chhoto-url/urls.sqlite";
            description = "The path of the sqlite database.";
            type = lib.types.path;
          };

          disable_frontend = lib.mkOption {
            default = false;
            description = "Whether to disable the frontend.";
            type = lib.types.bool;
          };

          hash_algorithm = lib.mkOption {
            default = null;

            description = ''
              The hash algorithm to use for passwords and API keys.
              Set to `null` if you want to provide these secrets as plaintext.
            '';

            type = lib.types.nullOr (lib.types.enum [ "Argon2" ]);
          };

          port = lib.mkOption {
            description = "The port to listen on.";
            example = 4567;
            type = lib.types.port;
          };

          public_mode = lib.mkOption {
            apply = x: if x then "Enable" else "Disable";
            default = false;
            description = "Whether to enable public mode.";
            type = lib.types.bool;
          };

          public_mode_expiry_delay = lib.mkOption {
            default = null;
            description = "The maximum expiry delay in seconds to force in public mode.";
            example = 3600;
            type = lib.types.nullOr lib.types.ints.unsigned;
          };

          redirect_method = lib.mkOption {
            default = "PERMANENT";
            description = "The redirect method to use.";

            type = lib.types.enum [
              "TEMPORARY"
              "PERMANENT"
            ];
          };

          site_url = lib.mkOption {
            default = null;
            description = "The URL under which Chhoto URL is externally reachable.";
            type = lib.types.nullOr lib.types.str;
          };

          slug_length = lib.mkOption {
            default = 8;
            description = "The length of auto-generated slugs.";
            type = lib.types.addCheck lib.types.int (x: x >= 4);
          };

          slug_style = lib.mkOption {
            default = "Pair";
            description = "The slug style to use for auto-generated URLs.";

            type = lib.types.enum [
              "Pair"
              "UID"
            ];
          };

          try_longer_slugs = lib.mkOption {
            default = false;
            description = "Whether to try a longer UID upon collision.";
            type = lib.types.bool;
          };
        };

        freeformType =
          with lib.types;
          attrsOf (oneOf [
            str
            int
            bool
          ]);
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.chhoto-url = {
      inherit environment;

      serviceConfig = {
        # hardening
        AmbientCapabilities = "";
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = lib.getExe cfg.package;
        Group = "chhoto-url";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
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
        RemoveIPC = true;
        RestrictAddressFamilies = [ "AF_INET AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SocketBindAllow = "tcp:${toString cfg.settings.port}";
        SocketBindDeny = "any";
        StateDirectory = "chhoto-url";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
        User = "chhoto-url";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ defelo ];
}
