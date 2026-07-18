{
  config,
  lib,
  pkgs,
  extendModules,
  noUserModules,
  ...
}:

let
  inherit (lib)
    concatStringsSep
    escapeShellArg
    hasInfix
    mapAttrs
    mapAttrsToList
    mkOption
    types
    ;

  # This attribute is responsible for creating boot entries for
  # child configuration. They are only (directly) accessible
  # when the parent configuration is boot default. For example,
  # you can provide an easy way to boot the same configuration
  # as you use, but with another kernel
  # !!! fix this
  children = mapAttrs (
    childName: childConfig: childConfig.configuration.system.build.toplevel
  ) config.specialisation;

in
{
  options = {
    isSpecialisation = mkOption {
      default = false;
      description = "Whether this system is a specialisation of another.";
      internal = true;
      type = lib.types.bool;
    };

    specialisation = mkOption {
      default = { };

      description = ''
        Additional configurations to build. If
        `inheritParentConfig` is true, the system
        will be based on the overall system configuration.

        To switch to a specialised configuration
        (e.g. `fewJobsManyCores`) at runtime, run:

        ```
        sudo /run/current-system/specialisation/fewJobsManyCores/bin/switch-to-configuration test
        ```
      '';

      example = lib.literalExpression "{ fewJobsManyCores.configuration = { nix.settings = { core = 0; max-jobs = 1; }; }; }";

      type = types.attrsOf (
        types.submodule (
          local@{ ... }:
          let
            extend = if local.config.inheritParentConfig then extendModules else noUserModules.extendModules;
          in
          {
            options.configuration = mkOption {
              inherit (extend { modules = [ ./no-clone.nix ]; }) type;
              default = { };

              description = ''
                Arbitrary NixOS configuration.

                Anything you can add to a normal NixOS configuration, you can add
                here, including imports and config values, although nested
                specialisations will be ignored.
              '';

              visible = "shallow";
            };

            options.inheritParentConfig = mkOption {
              default = true;
              description = "Include the entire system's configuration. Set to false to make a completely differently configured system.";
              type = types.bool;
            };
          }
        )
      );
    };

  };

  config = {
    assertions = mapAttrsToList (name: _: {
      assertion = !hasInfix "/" name;

      message = ''
        Specialisation names must not contain forward slashes.
        Invalid specialisation name: ${name}
      '';
    }) config.specialisation;

    system.systemBuilderCommands = ''
      mkdir $out/specialisation
      ${concatStringsSep "\n" (
        mapAttrsToList (name: path: "ln -s ${path} $out/specialisation/${escapeShellArg name}") children
      )}
    '';
  };

  # uses extendModules to generate a type
  meta.buildDocsInSandbox = false;
}
