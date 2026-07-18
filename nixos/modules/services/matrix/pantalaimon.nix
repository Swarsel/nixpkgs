{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.pantalaimon-headless;

  iniFmt = pkgs.formats.ini { };

  mkConfigFile =
    name: instanceConfig:
    iniFmt.generate "pantalaimon.conf" {
      ${name} = (
        lib.recursiveUpdate {
          Homeserver = instanceConfig.homeserver;
          # Set some settings to prevent user interaction for headless operation
          IgnoreVerification = true;
          ListenAddress = instanceConfig.listenAddress;
          ListenPort = instanceConfig.listenPort;
          SSL = instanceConfig.ssl;
          UseKeyring = false;
        } instanceConfig.extraSettings
      );

      Default = {
        LogLevel = instanceConfig.logLevel;
        Notifications = false;
      };
    };

  mkPantalaimonService =
    name: instanceConfig:
    lib.nameValuePair "pantalaimon-${name}" {
      after = [ "network-online.target" ];
      description = "pantalaimon instance ${name} - E2EE aware proxy daemon for matrix clients";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.pantalaimon-headless}/bin/pantalaimon --config ${mkConfigFile name instanceConfig} --data-path ${instanceConfig.dataPath}";
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
        StateDirectory = "pantalaimon-${name}";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
in
{
  options.services.pantalaimon-headless.instances = lib.mkOption {
    default = { };

    description = ''
      Declarative instance config.

      Note: to use pantalaimon interactively, e.g. for a Matrix client which does not
      support End-to-end encryption (like `fractal`), refer to the home-manager module.
    '';

    type = lib.types.attrsOf (lib.types.submodule (import ./pantalaimon-options.nix));
  };

  config = lib.mkIf (config.services.pantalaimon-headless.instances != { }) {
    systemd.services = lib.mapAttrs' mkPantalaimonService config.services.pantalaimon-headless.instances;
  };

  meta = {
    maintainers = with lib.maintainers; [ jojosch ];
  };
}
