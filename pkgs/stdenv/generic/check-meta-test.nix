# Execute with
#   nix-build -A nixosTests.nixpkgs-config-allow-unfree-packages-and-predicate --show-trace
#
# This test exercises the interaction between:
#
#   - nixos/modules/misc/nixpkgs.nix  (config merging, esp. allowUnfreePackages)
#   - pkgs/stdenv/generic/check-meta.nix (allowUnfreePredicate logic)
#
# It checks how:
#
#   * config.allowUnfreePackages
#   * config.allowUnfreePredicate
#
# interact to determine whether unfree packages are allowed.
{
  lib,
  pkgs,
}:

let
  inherit (lib)
    assertMsg
    generators
    licenses
    nameValuePair
    recurseIntoAttrs
    replaceString
    ;

  mkPkg = name: license: {
    pname = name;
    version = "1.0";
    meta.license = license;
  };

  assertValidity =
    {
      nixpkgsConfig,
      pkg,
      expected ? true,
    }:
    let
      testPkgs = import ../../.. {
        config = nixpkgsConfig;
        system = pkgs.stdenv.hostPlatform.system;
      };
      checkMeta = testPkgs.callPackage ./check-meta.nix { };
      tryEval = expression: builtins.tryEval (builtins.deepSeq expression expression);
      actual = tryEval (
        checkMeta.assertValidity pkgs.stdenv.hostPlatform {
          attrs = pkg;
          meta = pkg.meta;
        }
      );
      toPretty = generators.toPretty { };
    in
    assertMsg (actual.success == expected) ''
      Expected validity of package '${lib.getName pkg}' with unfree license
      '${licenses.toSPDX pkg.meta.license}' to be ${toPretty expected}, but got
      ${toPretty actual}
      with config:
      ${toPretty nixpkgsConfig}
    '';

  runAssertions = assertions: lib.deepSeq assertions "";

  mkTests = mkUnfreePkg: {
    allowAllUnfreePackages = assertValidity {
      nixpkgsConfig = {
        allowUnfree = true;
      };

      pkg = mkUnfreePkg "allowed";
    };

    allowOnlyFreePackagesByDefault = assertValidity {
      expected = false;
      nixpkgsConfig = { };
      pkg = mkUnfreePkg "forbidden";
    };

    allowUnfreePackagesOrPredicate =
      let
        nixpkgsConfig = {
          allowUnfreePackages = [ "allowed-by-packages" ];
          allowUnfreePredicate = pkg: lib.getName pkg == "allowed-by-predicate";
        };
      in
      runAssertions [
        (assertValidity {
          inherit nixpkgsConfig;
          pkg = mkUnfreePkg "allowed-by-packages";
        })
        (assertValidity {
          inherit nixpkgsConfig;
          pkg = mkUnfreePkg "allowed-by-predicate";
        })
        (assertValidity {
          inherit nixpkgsConfig;
          expected = false;
          pkg = mkUnfreePkg "forbidden";
        })
      ];

    allowUnfreePackagesWithPredicate =
      let
        nixpkgsConfig = {
          allowUnfreePredicate = pkg: lib.getName pkg == "allowed-by-predicate";
        };
      in
      [
        (assertValidity {
          inherit nixpkgsConfig;
          pkg = mkUnfreePkg "allowed-by-predicate";
        })
        (assertValidity {
          inherit nixpkgsConfig;
          expected = false;
          pkg = mkUnfreePkg "allowed-by-nothing";
        })
      ];

    allowUnfreeWithPackages = runAssertions [
      (assertValidity {
        expected = true;

        nixpkgsConfig = {
          allowUnfreePackages = [ "unfree" ];
        };

        pkg = mkUnfreePkg "unfree";
      })
    ];
  };

  unfreeLicenses = [
    licenses.unfree
    (licenses.AND [
      licenses.free
      licenses.unfree
    ])
  ];
in

recurseIntoAttrs (
  builtins.listToAttrs (
    map (
      license:
      nameValuePair (replaceString " " "-" (licenses.toSPDX license)) (
        recurseIntoAttrs (mkTests (name: mkPkg name license))
      )
    ) unfreeLicenses
  )
)
