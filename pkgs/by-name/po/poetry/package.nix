{
  lib,
  fetchFromGitHub,
  fetchPypi,
  python3,
}:

let
  newPackageOverrides =
    self: super:
    {
      poetry = self.callPackage ./unwrapped.nix { };

      # The versions of Poetry and poetry-core need to match exactly,
      # and poetry-core in nixpkgs requires a staging cycle to be updated,
      # so apply an override here.
      #
      # We keep the override around even when the versions match, as
      # it's likely to become relevant again after the next Poetry update.
      poetry-core = super.poetry-core.overridePythonAttrs (old: rec {
        version = "2.4.0";

        src = fetchFromGitHub {
          owner = "python-poetry";
          repo = "poetry-core";
          tag = version;
          hash = "sha256-i9EucMsoX8Z0iyhNDVYaczv1CSY/KaZpMjn/FGzIJU4=";
        };
      });
    }
    // (plugins self);
  python = python3.override (old: {
    packageOverrides = lib.composeManyExtensions (
      (if old ? packageOverrides then [ old.packageOverrides ] else [ ]) ++ [ newPackageOverrides ]
    );

    self = python;
  });

  plugins =
    ps: with ps; {
      poetry-audit-plugin = callPackage ./plugins/poetry-audit-plugin.nix { };
      poetry-plugin-export = callPackage ./plugins/poetry-plugin-export.nix { };
      poetry-plugin-migrate = callPackage ./plugins/poetry-plugin-migrate.nix { };
      poetry-plugin-poeblix = callPackage ./plugins/poetry-plugin-poeblix.nix { };
      poetry-plugin-shell = callPackage ./plugins/poetry-plugin-shell.nix { };
      poetry-plugin-up = callPackage ./plugins/poetry-plugin-up.nix { };
    };

  # selector is a function mapping pythonPackages to a list of plugins
  # e.g. poetry.withPlugins (ps: with ps; [ poetry-plugin-up ])
  withPlugins =
    selector:
    let
      selected = selector (plugins python.pkgs);
    in
    python.pkgs.toPythonApplication (
      python.pkgs.poetry.overridePythonAttrs (old: {
        # save some build time when adding plugins by disabling tests
        doCheck = selected == [ ];

        # Propagating dependencies leaks them through $PYTHONPATH which causes issues
        # when used in nix-shell.
        postFixup = ''
          rm $out/nix-support/propagated-build-inputs
        '';

        dependencies = old.dependencies ++ selected;

        passthru = {
          inherit withPlugins python;
          plugins = plugins python.pkgs;
        };
      })
    );
in
withPlugins (ps: [ ])
