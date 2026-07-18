{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.glance;

  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  settingsFormat = pkgs.formats.yaml { };
  settingsFile = "/run/glance/glance.yaml";
in
{
  options.services.glance = {
    enable = mkEnableOption "glance";
    package = mkPackageOption pkgs "glance" { };

    environmentFile = mkOption {
      default = "/dev/null";

      description =
        let
          singleQuotes = "''";
        in
        ''
          Path to an environment file as defined in {manpage}`systemd.exec(5)`.

          See upstream documentation
          <https://github.com/glanceapp/glance/blob/main/docs/configuration.md#environment-variables>.

          Example content of the file:
          ```
          TIMEZONE=Europe/Paris
          ```

          Example `services.glance.settings.pages` configuration:
          ```nix
            [
              {
                name = "Home";
                columns = [
                  {
                    size = "full";
                    widgets = [
                      {
                        type = "clock";
                        timezone = "\''${TIMEZONE}";
                        label = "Local Time";
                      }
                    ];
                  }
                ];
              }
            ];
          ```

          Note that when using Glance's `''${ENV_VAR}` syntax in Nix,
          you need to escape it as follows: use `\''${ENV_VAR}` in `"` strings
          and `${singleQuotes}''${ENV_VAR}` in `${singleQuotes}` strings.

          Alternatively, you can put each secret in it's own file,
          see `services.glance.settings`.
        '';

      example = "/var/lib/secrets/glance";
      type = types.nullOr types.path;
    };

    openFirewall = mkOption {
      default = false;

      description = ''
        Whether to open the firewall for Glance.
        This adds `services.glance.settings.server.port` to `networking.firewall.allowedTCPPorts`.
      '';

      type = types.bool;
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration written to a yaml file that is read by glance. See
        <https://github.com/glanceapp/glance/blob/main/docs/configuration.md>
        for more.

        Settings containing secret data should be set to an
        attribute set with this format: `{ _secret = "/path/to/secret"; }`.
        See the example in `services.glance.settings.pages` at the weather widget
        with a location secret to get a better picture of this.

        Alternatively, you can use a single file with environment variables,
        see `services.glance.environmentFile`.
      '';

      type = types.submodule {
        options = {
          pages = mkOption {
            default = [
              {
                columns = [
                  {
                    size = "full";
                    widgets = [ { type = "calendar"; } ];
                  }
                ];

                name = "Calendar";
              }
            ];

            description = ''
              List of pages to be present on the dashboard.

              See <https://github.com/glanceapp/glance/blob/main/docs/configuration.md#pages--columns>
            '';

            example = [
              {
                columns = [
                  {
                    size = "full";

                    widgets = [
                      { type = "calendar"; }
                      {
                        location = {
                          _secret = "/var/lib/secrets/glance/location";
                        };

                        type = "weather";
                      }
                    ];
                  }
                ];

                name = "Home";
              }
            ];

            type = settingsFormat.type;
          };

          server = {
            host = mkOption {
              default = "127.0.0.1";
              description = "Glance bind address";
              example = "0.0.0.0";
              type = types.str;
            };

            port = mkOption {
              default = 8080;
              description = "Glance port to listen on";
              example = 5678;
              type = types.port;
            };
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.settings.server.port ]; };

    systemd.services.glance = {
      # adding nss-user-lookup.target is a fix for https://github.com/NixOS/nixpkgs/issues/409348
      after = [
        "network.target"
        "nss-user-lookup.target"
      ];

      description = "Glance feed dashboard server";

      requires = [
        "nss-user-lookup.target"
      ];

      serviceConfig = {
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFile;
        ExecStart = "${getExe cfg.package} --config ${settingsFile}";

        ExecStartPre =
          # Use "+" to run as root because the secrets may not be accessible to glance
          "+"
          + pkgs.writeShellScript "glance-start-pre" ''
            ${utils.genJqSecretsReplacementSnippet cfg.settings settingsFile}
            chown $USER ${settingsFile}
          '';

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "all";
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "on-failure";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "glance";
        RuntimeDirectoryMode = "0755";
        StateDirectory = "glance";
        SystemCallArchitectures = "native";
        UMask = "0077";
        WorkingDirectory = "/var/lib/glance";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.doc = ./glance.md;

  meta.maintainers = with lib.maintainers; [
    gepbird
  ];
}
