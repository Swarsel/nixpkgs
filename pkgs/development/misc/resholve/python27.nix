{
  lib,
  pkgsBuildHost,
}:

let
  removeKnownVulnerabilities =
    pkg:
    pkg.overrideAttrs (old: {
      meta = (old.meta or { }) // {
        knownVulnerabilities = [ ];
      };
    });

  passthruFun = import ../../interpreters/python/passthrufun.nix {
    inherit lib;

    inherit (pkgsBuildHost)
      stdenv
      callPackage
      pythonPackagesExtensions
      config
      makeScopeWithSplicing'
      ;
  };

  python27Base = pkgsBuildHost.callPackage ./cpython-2.7 {
    inherit passthruFun;
    hash = "sha256-RuEgfpags9wJm9Xe0daotqUx4knABEUc7DvtgnQXEfE=";
    self = python27;

    sourceVersion = {
      major = "2";
      minor = "7";
      patch = "18";
      suffix = ".12"; # ActiveState's Python 2 extended support
    };
  };

  # We are removing `meta.knownVulnerabilities` from `python27`,
  # and setting it in `resholve` itself.
  python27 = (removeKnownVulnerabilities python27Base).override {
    bzip2 = null;
    enableOptimizations = false;
    gdbm = null;
    ncurses = null;
    # strip down that python version as much as possible
    openssl = null;

    # python2-only overrides for bootstrapped-pip/pip/setuptools/wheel
    # (no longer applied globally — kept local to resholve)
    packageOverrides = lib.composeExtensions (import ./python2-packages.nix) (
      _self: super: {
        pip = removeKnownVulnerabilities super.pip;
        setuptools = removeKnownVulnerabilities super.setuptools;
      }
    );

    pkgsBuildHost = pkgsBuildHost // {
      inherit python27;
    };

    readline = null;
    rebuildBytecode = false;
    self = python27;
    sqlite = null;
    strip2to3 = true;
    stripBytecode = true;
    stripConfig = true;
    stripIdlelib = true;
    stripTests = true;
  };
in
python27
