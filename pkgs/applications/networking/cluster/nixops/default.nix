{
  lib,
  config,
  emptyFile,
  python3,
}:

let
  inherit (lib) extends;

  # doc: https://github.com/NixOS/nixpkgs/pull/158781/files#diff-854251fa1fe071654921224671c8ba63c95feb2f96b2b3a9969c81676780053a
  encapsulate =
    layerZero:
    let
      fixed = layerZero ({ extend = f: encapsulate (extends f layerZero); } // fixed);
    in
    fixed.public;

  nixopsContextBase = this: {

    # We should not reapply the overlay, but it tends to work out. (It's been this way since poetry2nix was dropped.)
    availablePlugins = this.plugins this.python.pkgs this.python.pkgs;

    # Extra package attributes that aren't derivation attributes, just like `mkDerivation`'s `passthru`.
    extraPackageAttrs = {
      inherit (this)
        selectedPlugins
        availablePlugins
        withPlugins
        python
        ;

      /**
        nixops.addAvailablePlugins: Overlay -> Package

        Add available plugins to the package. You probably also want to enable
        them with the `withPlugins` method.
      */
      addAvailablePlugins =
        newPlugins:
        this.extend (
          finalThis: oldThis: {
            plugins = lib.composeExtensions oldThis.plugins newPlugins;
          }
        );

      # For those who need or dare.
      internals = this;

      overrideAttrs =
        f:
        this.extend (
          this: oldThis: {
            rawPackage = oldThis.rawPackage.overrideAttrs f;
          }
        );

      tests =
        this.rawPackage.tests
        // {
          commutative_addAvailablePlugins_withPlugins =
            assert
              (this.public.addAvailablePlugins (self: super: { inherit emptyFile; })).withPlugins (ps: [
                emptyFile
              ]) ==
              # Note that this value proves that the package is not instantiated until the end, where it's valid again.
              (this.public.withPlugins (ps: [ emptyFile ])).addAvailablePlugins (
                self: super: { inherit emptyFile; }
              );
            emptyFile;

          nixos = this.rawPackage.tests.nixos.passthru.override {
            nixopsPkg = this.rawPackage;
          };
        }
        # Make sure we also test with a configuration that's been extended with a plugin.
        // lib.optionalAttrs (this.selectedPlugins == [ ]) {
          withAPlugin =
            lib.recurseIntoAttrs
              (this.withPlugins (ps: with ps; [ nixops-encrypted-links ])).tests;
        };
    };

    package =
      lib.lazyDerivation {
        outputs = [
          "out"
          "dist"
        ];

        derivation = this.rawPackage;
      }
      // this.extraPackageAttrs;

    plugins =
      ps: _super:
      with ps;
      (
        rec {
          nixops-digitalocean = callPackage ./plugins/nixops-digitalocean.nix { };
          nixops-encrypted-links = callPackage ./plugins/nixops-encrypted-links.nix { };
          nixops-hercules-ci = callPackage ./plugins/nixops-hercules-ci.nix { };
          nixops-vbox = callPackage ./plugins/nixops-vbox.nix { };
          # aliases for backwards compatibility
          nixopsvbox = nixops-vbox;
          nixos-modules-contrib = callPackage ./plugins/nixos-modules-contrib.nix { };
        }
        // lib.optionalAttrs config.allowAliases rec {
          nixops-aws = throw "nixops-aws was broken and was removed from nixpkgs";
          nixops-gce = throw "nixops-gce was broken and was removed from nixpkgs";
          nixops-hetzner = throw "nixops-hetzner was broken and was removed from nixpkgs";
          nixops-hetznercloud = throw "nixops-hetznercloud was broken and was removed from nixpkgs";
          nixops-libvirtd = throw "nixops-libvirtd was broken and was removed from nixpkgs";
          nixops-virtd = nixops-libvirtd;
        }
      );

    public = this.package;

    python = python3.override {
      packageOverrides =
        self: super:
        {
          nixops = self.callPackage ./unwrapped.nix { };
        }
        // (this.plugins self super);

      self = this.python;
    };

    rawPackage = this.python.pkgs.toPythonApplication (
      this.python.pkgs.nixops.overridePythonAttrs (old: {
        propagatedBuildInputs = old.propagatedBuildInputs ++ this.selectedPlugins;

        # Propagating dependencies leaks them through $PYTHONPATH which causes issues
        # when used in nix-shell.
        postFixup = ''
          rm $out/nix-support/propagated-build-inputs
        '';
      })
    );

    selectedPlugins = [ ];

    # selector is a function mapping pythonPackages to a list of plugins
    # e.g. nixops_unstable.withPlugins (ps: with ps; [ nixops-digitalocean ])
    withPlugins =
      selector:
      this.extend (
        this: _old: {
          selectedPlugins = selector this.availablePlugins;
        }
      );
  };

  minimal = encapsulate nixopsContextBase;

in
{
  # Not recommended; too fragile.
  nixops_unstable_full = minimal.withPlugins (ps: [
    ps.nixops-digitalocean
    ps.nixops-encrypted-links
    ps.nixops-hercules-ci
    ps.nixops-vbox
  ]);

  nixops_unstable_minimal = minimal;
}
