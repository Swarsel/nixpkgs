{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  inherit (lib) types;

  cfg = config.services.orthanc;
  opt = options.services.orthanc;

  settingsFormat = pkgs.formats.json { };
in
{
  options = {
    services.orthanc = {
      enable = lib.mkEnableOption "Orthanc server";
      package = lib.mkPackageOption pkgs "orthanc" { };

      environment = lib.mkOption {
        default = {
        };

        description = ''
          Extra environment variables
          For more details see <https://orthanc.uclouvain.be/book/users/configuration.html>
        '';

        example = ''
          {
            ORTHANC_NAME = "Orthanc server";
          }
        '';

        type = types.attrsOf types.str;
      };

      environmentFile = lib.mkOption {
        default = null;

        description = ''
          Environment file to be passed to the systemd service.
          Useful for passing secrets to the service to prevent them from being
          world-readable in the Nix store.
        '';

        example = "/var/lib/secrets/orthancSecrets";
        type = lib.types.nullOr lib.types.path;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Whether to open the firewall for Orthanc.
          This adds `services.orthanc.settings.HttpPort` to `networking.firewall.allowedTCPPorts`.
        '';

        type = types.bool;
      };

      settings = lib.mkOption {
        default = {
          HttpPort = lib.mkDefault 8042;
          IndexDirectory = lib.mkDefault "/var/lib/orthanc/";
          StorageDirectory = lib.mkDefault "/var/lib/orthanc/";
        };

        description = ''
          Configuration written to a json file that is read by orthanc.
          See <https://orthanc.uclouvain.be/book/index.html> for more.
        '';

        example = {
          HttpPort = 12345;
          Name = "My Orthanc Server";
        };

        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };
      };

      stateDir = lib.mkOption {
        default = "/var/lib/orthanc";
        description = "State directory of Orthanc.";
        example = "/home/foo";
        type = types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.settings.HttpPort ]; };
    services.orthanc.settings = opt.settings.default;

    systemd.services.orthanc = {
      after = [ "network.target" ];
      description = "Orthanc is a lightweight, RESTful DICOM server for healthcare and medical research";
      environment = cfg.environment;

      serviceConfig =
        let
          config-json = settingsFormat.generate "orthanc-config.json" (cfg.settings);
        in
        {
          BindReadOnlyPaths = [
            "-/etc/localtime"
          ];

          DevicePolicy = "closed";
          DynamicUser = true;
          EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
          ExecStart = "${lib.getExe cfg.package} ${config-json}";
          LockPersonality = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RuntimeDirectory = "orthanc";
          RuntimeDirectoryMode = "0755";
          StateDirectory = "orthanc";
          SystemCallArchitectures = "native";
          UMask = "0077";
          WorkingDirectory = cfg.stateDir;
        };

      wantedBy = [ "multi-user.target" ];
    };

    # Orthanc requires /etc/localtime to be present
    time.timeZone = lib.mkDefault "UTC";
  };

  meta.maintainers = [ ];
}
