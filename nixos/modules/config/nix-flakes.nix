/*
  Manages the flake registry.

  See also
   - ./nix.nix
   - ./nix-channel.nix
*/
{ config, lib, ... }:
let
  inherit (lib)
    filterAttrs
    literalExpression
    mapAttrsToList
    mkDefault
    mkIf
    mkOption
    types
    ;

  cfg = config.nix;

  flakeRefFormat = ''
    The format of flake references is described in {manpage}`nix3-flake(1)`.
  '';

in
{
  options = {
    nix = {
      registry = mkOption {
        default = { };

        description = ''
          A system-wide flake registry.

          See {manpage}`nix3-registry(1)` for more information.
        '';

        type = types.attrsOf (
          types.submodule (
            let
              referenceAttrs =
                with types;
                attrsOf (oneOf [
                  str
                  int
                  bool
                  path
                  package
                ]);
            in
            { config, name, ... }:
            {
              options = {
                exact = mkOption {
                  default = true;

                  description = ''
                    Whether the {option}`from` reference needs to match exactly. If set,
                    a {option}`from` reference like `nixpkgs` does not
                    match with a reference like `nixpkgs/nixos-20.03`.
                  '';

                  type = types.bool;
                };

                flake = mkOption {
                  default = null;

                  description = ''
                    The flake input {option}`from` is rewritten to.
                  '';

                  example = literalExpression "nixpkgs";
                  type = types.nullOr types.attrs;
                };

                from = mkOption {
                  description = ''
                    The flake reference to be rewritten.

                    ${flakeRefFormat}
                  '';

                  example = {
                    id = "nixpkgs";
                    type = "indirect";
                  };

                  type = referenceAttrs;
                };

                to = mkOption {
                  description = ''
                    The flake reference {option}`from` is rewritten to.

                    ${flakeRefFormat}
                  '';

                  example = {
                    owner = "my-org";
                    repo = "my-nixpkgs";
                    type = "github";
                  };

                  type = referenceAttrs;
                };
              };

              config = {
                from = mkDefault {
                  id = name;
                  type = "indirect";
                };

                to = mkIf (config.flake != null) (
                  mkDefault (
                    {
                      path = config.flake.outPath;
                      type = "path";
                    }
                    // filterAttrs (n: _: n == "lastModified" || n == "rev" || n == "narHash") config.flake
                  )
                );
              };
            }
          )
        );
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc."nix/registry.json".text = builtins.toJSON {
      flakes = mapAttrsToList (n: v: { inherit (v) from to exact; }) cfg.registry;
      version = 2;
    };
  };
}
