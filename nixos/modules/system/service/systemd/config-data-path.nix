# Tests in: ../../tests/modular-service-etc/test.nix
# This module sets the path for configData entries in systemd services
let
  setPathsModule =
    prefix:
    { lib, name, ... }:
    let
      inherit (lib) mkOption types;
      servicePrefix = "${prefix}${name}";
    in
    {
      options = {
        # Extend portable configData option
        configData = mkOption {
          type = types.lazyAttrsOf (
            types.submodule (
              { config, ... }:
              {
                config = {
                  path = lib.mkDefault "/etc/system-services/${servicePrefix}/${config.name}";
                };
              }
            )
          );
        };

        services = mkOption {
          type = types.attrsOf (
            types.submoduleWith {
              modules = [
                (setPathsModule "${servicePrefix}-")
              ];
            }
          );
        };
      };

      _class = "service";
    };
in
setPathsModule ""
