{ lib, pkgs }:
{
  mkServarrEnvironmentFiles =
    name:
    lib.mkOption {
      default = [ ];

      description = ''
        Environment file to pass secret configuration values.
        Each line must follow the `${lib.toUpper name}__SECTION__KEY=value` pattern.
        Please consult the documentation at the [wiki](https://wiki.servarr.com/useful-tools#using-environment-variables-for-config).
      '';

      type = lib.types.listOf lib.types.path;
    };

  mkServarrSettingsEnvVars =
    name: settings:
    lib.pipe settings [
      (lib.mapAttrsRecursive (
        path: value:
        lib.optionalAttrs (value != null) {
          name = lib.toUpper "${name}__${lib.concatStringsSep "__" path}";
          value = toString (if lib.isBool value then lib.boolToString value else value);
        }
      ))
      (lib.collect (x: lib.isString x.name or false && lib.isString x.value or false))
      lib.listToAttrs
    ];

  mkServarrSettingsOptions =
    name: port:
    lib.mkOption {
      default = { };

      description = ''
        Attribute set of arbitrary config options.
        Please consult the documentation at the [wiki](https://wiki.servarr.com/useful-tools#using-environment-variables-for-config).

        WARNING: this configuration is stored in the world-readable Nix store!
        For secrets use [](#opt-services.${name}.environmentFiles).
      '';

      example = lib.options.literalExpression ''
        {
          update.mechanism = "internal";
          server = {
            urlbase = "localhost";
            port = ${toString port};
            bindaddress = "*";
          };
        }
      '';

      type = lib.types.submodule {
        options = {
          log = {
            analyticsEnabled = lib.mkOption {
              default = false;
              description = "Send Anonymous Usage Data";
              type = lib.types.bool;
            };
          };

          server = {
            port = lib.mkOption {
              default = port;
              description = "Port Number";
              type = lib.types.port;
            };
          };

          update = {
            automatically = lib.mkOption {
              default = false;
              description = "Automatically download and install updates.";
              type = lib.types.bool;
            };

            mechanism = lib.mkOption {
              default = "external";
              description = "which update mechanism to use";

              type =
                with lib.types;
                nullOr (enum [
                  "external"
                  "builtIn"
                  "script"
                ]);
            };
          };
        };

        freeformType = (pkgs.formats.ini { }).type;
      };
    };
}
