{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  fetchpatch,
  fetchzip,
  makeWrapper,
  newScope,
  ocamlPackages_4_14,
  ocamlPackages_5_4,
}@args:
let
  lib = import ../build-support/rocq/extra-lib.nix { inherit (args) lib; };
in
let
  mkRocqPackages' =
    self: rocq-core:
    let
      callPackage = self.callPackage;
    in
    {
      inherit rocq-core lib;
      bignums = callPackage ../development/rocq-modules/bignums { };
      filterPackages = doesFilter: if doesFilter then filterRocqPackages self else self;
      hierarchy-builder = callPackage ../development/rocq-modules/hierarchy-builder { };
      iris = callPackage ../development/rocq-modules/iris { };
      mathcomp = callPackage ../development/rocq-modules/mathcomp { };
      mathcomp-algebra = self.mathcomp.algebra;
      mathcomp-analysis = callPackage ../development/rocq-modules/mathcomp-analysis { };
      mathcomp-analysis-stdlib = self.mathcomp-analysis.analysis-stdlib;
      mathcomp-bigenough = callPackage ../development/rocq-modules/mathcomp-bigenough { };
      mathcomp-boot = self.mathcomp.boot;
      mathcomp-character = self.mathcomp-group-representation;
      mathcomp-classical = self.mathcomp-analysis.classical;
      mathcomp-experimental-reals = self.mathcomp-analysis.experimental-reals;
      mathcomp-field = self.mathcomp.field;
      mathcomp-fingroup = self.mathcomp-finite-group;
      mathcomp-finite-group = self.mathcomp.finite-group;
      mathcomp-finmap = callPackage ../development/rocq-modules/mathcomp-finmap { };
      mathcomp-group-representation = self.mathcomp.group-representation;
      mathcomp-order = self.mathcomp.order;
      mathcomp-real-closed = callPackage ../development/rocq-modules/mathcomp-real-closed { };
      mathcomp-reals = self.mathcomp-analysis.reals;
      mathcomp-reals-stdlib = self.mathcomp-analysis.reals-stdlib;
      mathcomp-solvable = self.mathcomp.solvable;

      metaFetch = import ../build-support/rocq/meta-fetch/default.nix {
        inherit
          lib
          stdenv
          fetchzip
          fetchurl
          ;
      };

      micromega-plugin = callPackage ../development/rocq-modules/micromega-plugin { };
      mkRocqDerivation = lib.makeOverridable (callPackage ../build-support/rocq { });
      parseque = callPackage ../development/rocq-modules/parseque { };
      relation-algebra = callPackage ../development/rocq-modules/relation-algebra { };
      rocq-elpi = callPackage ../development/rocq-modules/rocq-elpi { };

      rocqPackages = self // {
        __attrsFailEvaluation = true;
        recurseForDerivations = false;
      };

      rocqnavi = callPackage ../development/rocq-modules/rocqnavi { };
      stdlib = callPackage ../development/rocq-modules/stdlib { };
      stdpp = callPackage ../development/rocq-modules/stdpp { };
      vsrocq-language-server = callPackage ../development/rocq-modules/vsrocq-language-server { };
    };

  filterRocqPackages =
    set:
    lib.listToAttrs (
      lib.concatMap (
        name:
        let
          v = set.${name} or null;
        in
        lib.optional (!v.meta.rocqFilter or false) (
          lib.nameValuePair name (
            if lib.isAttrs v && v.recurseForDerivations or false then filterRocqPackages v else v
          )
        )
      ) (lib.attrNames set)
    );
  mkRocq =
    version:
    callPackage ../applications/science/logic/rocq-core {
      inherit
        version
        ocamlPackages_4_14
        ocamlPackages_5_4
        ;
    };
in
rec {

  /*
    The function `mkRocqPackages` takes as input a derivation for Rocq and produces
    a set of libraries built with that specific Rocq. More libraries are known to
    this function than what is compatible with that version of Rocq. Therefore,
    libraries that are not known to be compatible are removed (filtered out) from
    the resulting set. For meta-programming purposes (inspecting the derivations
    rather than building the libraries) this filtering can be disabled by setting
    a `dontFilter` attribute into the Rocq derivation.
  */
  mkRocqPackages =
    rocq-core:
    let
      self = lib.makeScope newScope (lib.flip mkRocqPackages' rocq-core);
    in
    self.filterPackages (!rocq-core.dontFilter or false);

  rocq-core = rocqPackages.rocq-core;
  rocq-core_9_0 = mkRocq "9.0";
  rocq-core_9_1 = mkRocq "9.1";
  rocq-core_9_2 = mkRocq "9.2";
  rocqPackages = lib.recurseIntoAttrs rocqPackages_9_1;
  rocqPackages_9_0 = mkRocqPackages rocq-core_9_0;
  rocqPackages_9_1 = mkRocqPackages rocq-core_9_1;
  rocqPackages_9_2 = mkRocqPackages rocq-core_9_2;
}
