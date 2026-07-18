{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  coq2html,
  dune,
  fetchpatch,
  fetchzip,
  makeWrapper,
  newScope,
  ocamlPackages_4_09,
  ocamlPackages_4_10,
  ocamlPackages_4_12,
  ocamlPackages_4_14,
  ocamlPackages_5_4,
  rocqPackages,
  rocqPackages_9_0,
  rocqPackages_9_1,
  rocqPackages_9_2,
}@args:
let
  lib = import ../build-support/coq/extra-lib.nix { inherit (args) lib; };
in
let
  mkCoqPackages' =
    self: coq:
    let
      callPackage = self.callPackage;
      rocqPackages = self // {
        recurseForDerivations = false;
      };
    in
    {
      inherit rocqPackages lib;
      CakeMLExtraction = callPackage ../development/coq-modules/CakeMLExtraction { };
      CertiRocq = callPackage ../development/coq-modules/CertiRocq { };
      Cheerios = callPackage ../development/coq-modules/Cheerios { };

      CoLoR = callPackage ../development/coq-modules/CoLoR (
        lib.optionalAttrs (lib.versions.isEq self.coq.coq-version "8.13") {
          bignums = self.bignums.override { version = "8.13.0"; };
        }
      );

      ConCert = callPackage ../development/coq-modules/ConCert { };
      CoqMatrix = callPackage ../development/coq-modules/coq-matrix { };
      ElmExtraction = callPackage ../development/coq-modules/ElmExtraction { };
      ExtLib = callPackage ../development/coq-modules/ExtLib { };
      HoTT = callPackage ../development/coq-modules/HoTT { };
      ITree = callPackage ../development/coq-modules/ITree { };
      InfSeqExt = callPackage ../development/coq-modules/InfSeqExt { };
      LibHyps = callPackage ../development/coq-modules/LibHyps { };
      MenhirLib = callPackage ../development/coq-modules/MenhirLib { };
      Ordinal = callPackage ../development/coq-modules/Ordinal { };
      QuickChick = callPackage ../development/coq-modules/QuickChick { };
      RustExtraction = callPackage ../development/coq-modules/RustExtraction { };
      StructTact = callPackage ../development/coq-modules/StructTact { };
      TypedExtraction = callPackage ../development/coq-modules/TypedExtraction { };
      TypedExtraction-common = self.TypedExtraction.common;
      TypedExtraction-elm = self.TypedExtraction.elm;
      TypedExtraction-plugin = self.TypedExtraction.plugin;
      TypedExtraction-rust = self.TypedExtraction.rust;

      VST = callPackage ../development/coq-modules/VST (
        (lib.optionalAttrs (lib.versionAtLeast self.coq.version "8.14") {
          compcert = self.compcert.override {
            version =
              with lib.versions;
              lib.switch self.coq.version [
                {
                  case = range "8.15" "8.18";
                  out = "3.13.1";
                }
                {
                  case = isEq "8.14";
                  out = "3.11";
                }
              ] null;
          };
        })
        // (lib.optionalAttrs (lib.versions.isEq self.coq.coq-version "8.13") {
          ITree = self.ITree.override {
            version = "4.0.0";
            paco = self.paco.override { version = "4.1.2"; };
          };
        })
      );

      Velisarios = callPackage ../development/coq-modules/Velisarios { };
      Verdi = callPackage ../development/coq-modules/Verdi { };
      Vpl = callPackage ../development/coq-modules/Vpl { };
      VplTactic = callPackage ../development/coq-modules/VplTactic { };
      aac-tactics = callPackage ../development/coq-modules/aac-tactics { };
      addition-chains = callPackage ../development/coq-modules/addition-chains { };
      async-test = callPackage ../development/coq-modules/async-test { };
      atbr = callPackage ../development/coq-modules/atbr { };
      autosubst = callPackage ../development/coq-modules/autosubst { };
      autosubst-ocaml = callPackage ../development/coq-modules/autosubst-ocaml { };
      bbv = callPackage ../development/coq-modules/bbv { };

      bignums =
        if lib.versionAtLeast coq.coq-version "8.6" then
          callPackage ../development/coq-modules/bignums { }
        else
          null;

      category-theory = callPackage ../development/coq-modules/category-theory { };
      ceres = callPackage ../development/coq-modules/ceres { };
      ceres-bs = callPackage ../development/coq-modules/ceres-bs { };
      coinduction = callPackage ../development/coq-modules/coinduction { };

      compcert = callPackage ../development/coq-modules/compcert {
        inherit
          fetchpatch
          makeWrapper
          coq2html
          lib
          stdenv
          ;
      };

      contribs = lib.recurseIntoAttrs (callPackage ../development/coq-modules/contribs { });

      coq = coq.overrideAttrs (oldAttrs: {
        passthru = (oldAttrs.passthru or { }) // {
          withPackages =
            f:
            (callPackage ../applications/science/logic/coq/with-packages.nix {
              inherit coq;
            })
              (f self);
        };
      });

      coq-bits = callPackage ../development/coq-modules/coq-bits { };
      coq-elpi = callPackage ../development/coq-modules/coq-elpi { };
      coq-hammer = callPackage ../development/coq-modules/coq-hammer { };
      coq-hammer-tactics = callPackage ../development/coq-modules/coq-hammer/tactics.nix { };
      coq-haskell = callPackage ../development/coq-modules/coq-haskell { };
      coq-lsp = callPackage ../development/coq-modules/coq-lsp { };
      coq-record-update = callPackage ../development/coq-modules/coq-record-update { };
      coq-tactical = callPackage ../development/coq-modules/coq-tactical { };

      coqeal = callPackage ../development/coq-modules/coqeal (
        lib.optionalAttrs (lib.versions.range "8.13" "8.14" self.coq.coq-version) {
          bignums = self.bignums.override { version = "${self.coq.coq-version}.0"; };
        }
      );

      coqfmt = callPackage ../development/coq-modules/coqfmt { };
      coqhammer = callPackage ../development/coq-modules/coqhammer { };
      coqide = callPackage ../development/coq-modules/coqide { };
      coqprime = callPackage ../development/coq-modules/coqprime { };
      coqtail-math = callPackage ../development/coq-modules/coqtail-math { };
      coquelicot = callPackage ../development/coq-modules/coquelicot { };
      coqutil = callPackage ../development/coq-modules/coqutil { };
      corn = callPackage ../development/coq-modules/corn { };
      deriving = callPackage ../development/coq-modules/deriving { };
      dpdgraph = callPackage ../development/coq-modules/dpdgraph { };
      equations = callPackage ../development/coq-modules/equations { };
      extructures = callPackage ../development/coq-modules/extructures { };
      fcsl-pcm = callPackage ../development/coq-modules/fcsl-pcm { };
      filterPackages = doesFilter: if doesFilter then filterCoqPackages self else self;
      flocq = callPackage ../development/coq-modules/flocq { };
      fourcolor = callPackage ../development/coq-modules/fourcolor { };
      gaia = callPackage ../development/coq-modules/gaia { };
      gaia-hydras = callPackage ../development/coq-modules/gaia-hydras { };
      gappalib = callPackage ../development/coq-modules/gappalib { };
      goedel = callPackage ../development/coq-modules/goedel { };
      graph-theory = callPackage ../development/coq-modules/graph-theory { };
      heq = callPackage ../development/coq-modules/heq { };
      hierarchy-builder = callPackage ../development/coq-modules/hierarchy-builder { };
      high-school-geometry = callPackage ../development/coq-modules/high-school-geometry { };
      http = callPackage ../development/coq-modules/http { };
      hydra-battles = callPackage ../development/coq-modules/hydra-battles { };
      interval = callPackage ../development/coq-modules/interval { };
      iris = callPackage ../development/coq-modules/iris { };
      iris-named-props = callPackage ../development/coq-modules/iris-named-props { };
      itauto = callPackage ../development/coq-modules/itauto { };
      itree-io = callPackage ../development/coq-modules/itree-io { };
      jasmin = callPackage ../development/coq-modules/jasmin { };
      json = callPackage ../development/coq-modules/json { };
      lemma-overloading = callPackage ../development/coq-modules/lemma-overloading { };
      libvalidsdp = self.validsdp.libvalidsdp;
      ltac2 = callPackage ../development/coq-modules/ltac2 { };
      math-classes = callPackage ../development/coq-modules/math-classes { };
      mathcomp = callPackage ../development/coq-modules/mathcomp { };
      mathcomp-abel = callPackage ../development/coq-modules/mathcomp-abel { };
      mathcomp-algebra = self.mathcomp.algebra;
      mathcomp-algebra-tactics = callPackage ../development/coq-modules/mathcomp-algebra-tactics { };
      mathcomp-analysis = callPackage ../development/coq-modules/mathcomp-analysis { };
      mathcomp-analysis-stdlib = self.mathcomp-analysis.analysis-stdlib;
      mathcomp-apery = callPackage ../development/coq-modules/mathcomp-apery { };
      mathcomp-bigenough = callPackage ../development/coq-modules/mathcomp-bigenough { };
      mathcomp-boot = self.mathcomp.boot;
      mathcomp-character = self.mathcomp.character;
      mathcomp-classical = self.mathcomp-analysis.classical;
      mathcomp-experimental-reals = self.mathcomp-analysis.experimental-reals;
      mathcomp-field = self.mathcomp.field;
      mathcomp-fingroup = self.mathcomp.fingroup;
      mathcomp-finite-group = self.mathcomp.fingroup;
      mathcomp-finmap = callPackage ../development/coq-modules/mathcomp-finmap { };
      mathcomp-group-representation = self.mathcomp.character;
      mathcomp-infotheo = callPackage ../development/coq-modules/mathcomp-infotheo { };
      mathcomp-order = self.mathcomp.order;
      mathcomp-real-closed = callPackage ../development/coq-modules/mathcomp-real-closed { };
      mathcomp-reals = self.mathcomp-analysis.reals;
      mathcomp-reals-stdlib = self.mathcomp-analysis.reals-stdlib;
      mathcomp-solvable = self.mathcomp.solvable;
      mathcomp-ssreflect = self.mathcomp.ssreflect;
      mathcomp-tarjan = callPackage ../development/coq-modules/mathcomp-tarjan { };
      mathcomp-word = callPackage ../development/coq-modules/mathcomp-word { };
      mathcomp-zify = callPackage ../development/coq-modules/mathcomp-zify { };

      metaFetch = import ../build-support/rocq/meta-fetch/default.nix {
        inherit
          lib
          stdenv
          fetchzip
          fetchurl
          ;
      };

      metacoq = callPackage ../development/coq-modules/metacoq { };
      metacoq-common = self.metacoq.common;
      metacoq-erasure = self.metacoq.erasure;
      metacoq-erasure-plugin = self.metacoq.erasure-plugin;
      metacoq-pcuic = self.metacoq.pcuic;
      metacoq-quotation = self.metacoq.quotation;
      metacoq-safechecker = self.metacoq.safechecker;
      metacoq-safechecker-plugin = self.metacoq.safechecker-plugin;
      metacoq-template-coq = self.metacoq.template-coq;
      metacoq-template-pcuic = self.metacoq.template-pcuic;
      metacoq-translations = self.metacoq.translations;
      metacoq-utils = self.metacoq.utils;
      metalib = callPackage ../development/coq-modules/metalib { };
      metarocq = callPackage ../development/coq-modules/metarocq { };
      metarocq-common = self.metarocq.common;
      metarocq-erasure = self.metarocq.erasure;
      metarocq-erasure-plugin = self.metarocq.erasure-plugin;
      metarocq-pcuic = self.metarocq.pcuic;
      metarocq-quotation = self.metarocq.quotation;
      metarocq-safechecker = self.metarocq.safechecker;
      metarocq-safechecker-plugin = self.metarocq.safechecker-plugin;
      metarocq-template-pcuic = self.metarocq.template-pcuic;
      metarocq-template-rocq = self.metarocq.template-rocq;
      metarocq-translations = self.metarocq.translations;
      metarocq-utils = self.metarocq.utils;

      mkCoqDerivation =
        args:
        self.mkRocqDerivation (
          {
            namePrefix = [ "coq" ];
            useCoq = true;
          }
          // args
        );

      mkRocqDerivation = lib.makeOverridable (callPackage ../build-support/rocq { });
      mtac2 = callPackage ../development/coq-modules/mtac2 { };
      multinomials = callPackage ../development/coq-modules/multinomials { };
      odd-order = callPackage ../development/coq-modules/odd-order { };
      paco = callPackage ../development/coq-modules/paco { };
      paramcoq = callPackage ../development/coq-modules/paramcoq { };
      parsec = callPackage ../development/coq-modules/parsec { };
      parseque = callPackage ../development/coq-modules/parseque { };
      pocklington = callPackage ../development/coq-modules/pocklington { };
      reglang = callPackage ../development/coq-modules/reglang { };
      relation-algebra = callPackage ../development/coq-modules/relation-algebra { };
      rewriter = callPackage ../development/coq-modules/rewriter { };
      semantics = callPackage ../development/coq-modules/semantics { };
      serapi = callPackage ../development/coq-modules/serapi { };
      simple-io = callPackage ../development/coq-modules/simple-io { };
      smpl = callPackage ../development/coq-modules/smpl { };
      smtcoq = callPackage ../development/coq-modules/smtcoq { };
      ssprove = callPackage ../development/coq-modules/ssprove { };
      ssreflect = self.mathcomp.ssreflect;
      stalmarck = self.stalmarck-tactic.stalmarck;
      stalmarck-tactic = callPackage ../development/coq-modules/stalmarck { };
      stdlib = callPackage ../development/coq-modules/stdlib { };
      stdpp = callPackage ../development/coq-modules/stdpp { };
      tlc = callPackage ../development/coq-modules/tlc { };
      topology = callPackage ../development/coq-modules/topology { };
      trakt = callPackage ../development/coq-modules/trakt { };
      unicoq = callPackage ../development/coq-modules/unicoq { };
      validsdp = callPackage ../development/coq-modules/validsdp { };

      vcfloat = callPackage ../development/coq-modules/vcfloat (
        lib.optionalAttrs (lib.versions.range "8.16" "8.18" self.coq.version) {
          interval = self.interval.override { version = "4.9.0"; };
        }
      );

      verified-extraction = callPackage ../development/coq-modules/verified-extraction { };
      vscoq-language-server = callPackage ../development/coq-modules/vscoq-language-server { };
      vsrocq-language-server = callPackage ../development/rocq-modules/vsrocq-language-server { };
      wasmcert = callPackage ../development/coq-modules/wasmcert { };
      waterproof = callPackage ../development/coq-modules/waterproof { };
      zorns-lemma = callPackage ../development/coq-modules/zorns-lemma { };
    };

  filterCoqPackages =
    set:
    lib.listToAttrs (
      lib.concatMap (
        name:
        let
          v = set.${name} or null;
        in
        lib.optional (!v.meta.rocqFilter or false) (
          lib.nameValuePair name (
            if lib.isAttrs v && v.recurseForDerivations or false then filterCoqPackages v else v
          )
        )
      ) (lib.attrNames set)
    );
  mkCoq =
    version: rp:
    callPackage ../applications/science/logic/coq {
      inherit
        version
        ocamlPackages_4_09
        ocamlPackages_4_10
        ocamlPackages_4_12
        ocamlPackages_4_14
        ocamlPackages_5_4
        ;

      rocqPackages = rp;
    };
in
rec {

  coq = coqPackages.coq;
  coqPackages = lib.recurseIntoAttrs coqPackages_9_1;
  coqPackages_8_10 = mkCoqPackages (mkCoq "8.10" { });
  coqPackages_8_11 = mkCoqPackages (mkCoq "8.11" { });
  coqPackages_8_12 = mkCoqPackages (mkCoq "8.12" { });
  coqPackages_8_13 = mkCoqPackages (mkCoq "8.13" { });
  coqPackages_8_14 = mkCoqPackages (mkCoq "8.14" { });
  coqPackages_8_15 = mkCoqPackages (mkCoq "8.15" { });
  coqPackages_8_16 = mkCoqPackages (mkCoq "8.16" { });
  coqPackages_8_17 = mkCoqPackages (mkCoq "8.17" { });
  coqPackages_8_18 = mkCoqPackages (mkCoq "8.18" { });
  coqPackages_8_19 = mkCoqPackages (mkCoq "8.19" { });
  coqPackages_8_20 = mkCoqPackages (mkCoq "8.20" { });
  coqPackages_8_7 = mkCoqPackages (mkCoq "8.7" { });
  coqPackages_8_8 = mkCoqPackages (mkCoq "8.8" { });
  coqPackages_8_9 = mkCoqPackages (mkCoq "8.9" { });
  coqPackages_9_0 = mkCoqPackages (mkCoq "9.0" rocqPackages_9_0);
  coqPackages_9_1 = mkCoqPackages (mkCoq "9.1" rocqPackages_9_1);
  coqPackages_9_2 = mkCoqPackages (mkCoq "9.2" rocqPackages_9_2);
  coq_8_10 = coqPackages_8_10.coq;
  coq_8_11 = coqPackages_8_11.coq;
  coq_8_12 = coqPackages_8_12.coq;
  coq_8_13 = coqPackages_8_13.coq;
  coq_8_14 = coqPackages_8_14.coq;
  coq_8_15 = coqPackages_8_15.coq;
  coq_8_16 = coqPackages_8_16.coq;
  coq_8_17 = coqPackages_8_17.coq;
  coq_8_18 = coqPackages_8_18.coq;
  coq_8_19 = coqPackages_8_19.coq;
  coq_8_20 = coqPackages_8_20.coq;
  coq_8_7 = coqPackages_8_7.coq;
  coq_8_8 = coqPackages_8_8.coq;
  coq_8_9 = coqPackages_8_9.coq;
  coq_9_0 = coqPackages_9_0.coq;
  coq_9_1 = coqPackages_9_1.coq;
  coq_9_2 = coqPackages_9_2.coq;

  /*
    The function `mkCoqPackages` takes as input a derivation for Coq and produces
    a set of libraries built with that specific Coq. More libraries are known to
    this function than what is compatible with that version of Coq. Therefore,
    libraries that are not known to be compatible are removed (filtered out) from
    the resulting set. For meta-programming purposes (inspecting the derivations
    rather than building the libraries) this filtering can be disabled by setting
    a `dontFilter` attribute into the Coq derivation.
  */
  mkCoqPackages =
    coq:
    let
      self = lib.makeScope newScope (lib.flip mkCoqPackages' coq);
    in
    self.filterPackages (!coq.dontFilter or false);
}
