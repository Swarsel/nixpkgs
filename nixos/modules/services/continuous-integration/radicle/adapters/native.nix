{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.radicle.ci.adapters.native;
  brokerCfg = config.services.radicle.ci.broker;

  settingsFormat = pkgs.formats.yaml { };

  enabledInstances = lib.filter (instance: instance.enable) (lib.attrValues cfg.instances);
in

{
  options.services.radicle.ci.adapters.native = {
    instances = lib.mkOption {
      default = { };
      description = "radicle-native-ci adapter instances.";

      type = lib.types.attrsOf (
        lib.types.submodule (
          { config, name, ... }:
          {
            options = {
              enable = lib.mkEnableOption "this radicle-native-ci instance" // {
                default = true;
                example = false;
              };

              package = lib.mkPackageOption pkgs "radicle-native-ci" { };

              name = lib.mkOption {
                description = ''
                  Adapter name that is used in the radicle-ci-broker configuration.
                  Defaults to the attribute name.
                '';

                type = lib.types.str;
              };

              runtimePackages = lib.mkOption {
                defaultText = lib.literalExpression ''
                  with pkgs; [
                    bash
                    coreutils
                    curl
                    gawk
                    gitMinimal
                    gnused
                    wget
                  ]
                '';

                description = "Packages added to the adapter's {env}`PATH`.";
                type = lib.types.listOf lib.types.package;
              };

              settings = lib.mkOption {
                default = { };

                description = ''
                  Configuration of radicle-native-ci.
                  See <https://radicle.network/nodes/seed.radicle.dev/rad:z3qg5TKmN83afz2fj9z3fQjU8vaYE#configuration> for more information.
                '';

                type = lib.types.submodule {
                  options = {
                    base_url = lib.mkOption {
                      default = null;
                      description = "Base URL for build logs (mandatory for access from CI broker page).";
                      type = lib.types.nullOr lib.types.str;
                    };

                    log = lib.mkOption {
                      defaultText = lib.literalExpression ''"''${config.services.radicle.ci.broker.logDir}/adapters/native/${config.name}.log"'';
                      description = "File where radicle-native-ci should write the run log.";
                      type = lib.types.path;
                    };

                    state = lib.mkOption {
                      defaultText = lib.literalExpression ''"''${config.services.radicle.ci.broker.stateDir}/adapters/native/${config.name}"'';
                      description = "Directory where per-run directories are stored.";
                      type = lib.types.path;
                    };
                  };

                  freeformType = settingsFormat.type;
                };
              };
            };

            config = {
              name = lib.mkDefault name;

              runtimePackages = with pkgs; [
                bash
                coreutils
                curl
                gawk
                gitMinimal
                gnused
                wget
              ];

              settings = {
                log = lib.mkDefault "${brokerCfg.logDir}/adapters/native/${config.name}.log";
                state = lib.mkDefault "${brokerCfg.stateDir}/adapters/native/${config.name}";
              };
            };
          }
        )
      );
    };
  };

  config = lib.mkIf (enabledInstances != [ ]) {
    services.radicle.ci.broker.settings.adapters = lib.listToAttrs (
      map (
        instance:
        lib.nameValuePair instance.name {
          config = instance.settings;
          command = lib.getExe instance.package;
          config_env = "RADICLE_NATIVE_CI";
          env.PATH = lib.makeBinPath instance.runtimePackages;
        }
      ) enabledInstances
    );

    systemd.tmpfiles.settings.radicle-native-ci = lib.listToAttrs (
      map (
        instance:
        lib.nameValuePair (dirOf instance.settings.log) {
          d = {
            group = config.users.groups.radicle.name;
            user = config.users.users.radicle.name;
          };
        }
      ) enabledInstances
    );
  };

  meta.teams = [ lib.teams.radicle ];
}
