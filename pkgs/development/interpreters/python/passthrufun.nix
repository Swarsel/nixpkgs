{
  lib,
  stdenv,
  callPackage,
  config,
  makeScopeWithSplicing',
  pythonPackagesExtensions,
  ...
}:

{
  executable,
  hasDistutilsCxxPatch,
  implementation,
  libPrefix,
  packageOverrides,
  pythonOnBuildForBuild,
  pythonOnBuildForHost,
  pythonOnBuildForTarget,
  pythonOnHostForHost,
  pythonOnTargetForTarget,
  pythonVersion,
  self, # is pythonOnHostForTarget
  sitePackages,
  sourceVersion,
  pythonABITags ? [ "none" ],
  pythonAttr ? null,
}:
let
  pythonPackages =
    let
      ensurePythonModules =
        items:
        let
          exceptions = [
            stdenv
          ];
          providesSetupHook = lib.attrByPath [ "provides" "setupHook" ] false;
          valid =
            value: pythonPackages.hasPythonModule value || providesSetupHook value || lib.elem value exceptions;
          func =
            name: value:
            if lib.isDerivation value then
              lib.extendDerivation (
                valid value
                || throw "${name} should use `buildPythonPackage` or `toPythonModule` if it is to be part of the Python packages set."
              ) { } value
            else
              value;
        in
        lib.mapAttrs func items;
    in
    ensurePythonModules (
      callPackage
        # Function that when called
        # - imports python-packages.nix
        # - adds spliced package sets to the package set
        # - applies overrides from `packageOverrides` and `pythonPackagesOverlays`.
        (
          {
            stdenv,
            overrides,
            pkgs,
            python,
          }:
          let
            pythonPackagesFun = import ./python-packages-base.nix {
              inherit stdenv pkgs lib;
              python = self;
            };
            otherSplices = {
              selfBuildBuild = pythonOnBuildForBuild.pkgs;
              selfBuildHost = pythonOnBuildForHost.pkgs;
              selfBuildTarget = pythonOnBuildForTarget.pkgs;
              selfHostHost = pythonOnHostForHost.pkgs;
              selfTargetTarget = pythonOnTargetForTarget.pkgs or { }; # There is no Python TargetTarget.
            };
            hooks = import ./hooks/default.nix;
            keep = self: hooks self { };
            optionalExtensions = cond: as: lib.optionals cond as;
            pythonExtension = import ../../../top-level/python-packages.nix;
            python2Extension = import ../../misc/resholve/python2-packages.nix;
            extensions = lib.composeManyExtensions (
              [
                hooks
                pythonExtension
              ]
              ++ (optionalExtensions (!self.isPy3k) [
                python2Extension
              ])
              ++ pythonPackagesExtensions
              ++ [
                overrides
              ]
            );
            aliases =
              self: super:
              lib.optionalAttrs config.allowAliases (import ../../../top-level/python-aliases.nix lib self super);
          in
          makeScopeWithSplicing' {
            inherit otherSplices keep;
            f = lib.extends (lib.composeExtensions aliases extensions) pythonPackagesFun;
          }
        )
        {
          overrides = packageOverrides;
          python = self;
        }
    );
in
rec {
  inherit
    executable
    implementation
    libPrefix
    pythonVersion
    sitePackages
    ;

  inherit sourceVersion;
  inherit hasDistutilsCxxPatch;

  inherit
    pythonOnBuildForBuild
    pythonOnBuildForHost
    pythonOnBuildForTarget
    pythonOnHostForHost
    pythonOnTargetForTarget
    ;

  inherit pythonABITags;
  inherit pythonAttr;

  buildEnv = callPackage ./wrapper.nix {
    inherit (pythonPackages) requiredPythonModules;
    python = self;
  };

  interpreter = "${self}/bin/${executable}";
  isPy3 = lib.strings.substring 0 1 pythonVersion == "3";
  isPy311 = pythonVersion == "3.11";
  isPy312 = pythonVersion == "3.12";
  isPy313 = pythonVersion == "3.13";
  isPy314 = pythonVersion == "3.14";
  isPy3k = isPy3;
  isPyPy = lib.hasInfix "pypy" interpreter;
  pkgs = pythonPackages;
  pythonAtLeast = lib.versionAtLeast pythonVersion;
  pythonOlder = lib.versionOlder pythonVersion;

  tests = callPackage ./tests.nix {
    python = self;
  };

  withPackages = import ./with-packages.nix { inherit buildEnv pythonPackages; };
}
