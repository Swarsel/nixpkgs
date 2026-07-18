{
  lib,
  stdenv,
  fetchurl,
  binutils,
  binutilsNoLibc,
  buildGccPackages,
  fetchgit,
  makeScopeWithSplicing',
  newScope,
  otherSplices,
  overrideCC,
  targetGccPackages,
  wrapCCWith,
  gitRelease ? null,
  monorepoSrc ? null,
  officialRelease ? null,
  patchesFn ? lib.id,
  version ? null,
  ...
}@args:

assert lib.assertMsg (lib.xor (gitRelease != null) (officialRelease != null)) (
  "must specify `gitRelease` or `officialRelease`"
  + (lib.optionalString (gitRelease != null) " — not both")
);

let
  monorepoSrc' = monorepoSrc;

  metadata = rec {
    inherit
      (import ./common-let.nix {
        inherit (args)
          lib
          gitRelease
          officialRelease
          version
          ;
      })
      releaseInfo
      ;

    inherit (releaseInfo) release_version version;

    inherit
      (import ./common-let.nix {
        inherit
          lib
          fetchgit
          fetchurl
          release_version
          gitRelease
          officialRelease
          monorepoSrc'
          version
          ;
      })
      gcc_meta
      monorepoSrc
      ;

    src = monorepoSrc;

    getVersionFile =
      p:
      builtins.path {
        name = baseNameOf p;

        path =
          let
            patches = args.patchesFn (import ./patches.nix);

            constraints = patches."${p}" or null;
            matchConstraint =
              {
                path,
                after ? null,
                before ? null,
              }:
              let
                check = fn: value: if value == null then true else fn release_version value;
                matchBefore = check lib.versionOlder before;
                matchAfter = check lib.versionAtLeast after;
              in
              matchBefore && matchAfter;

            patchDir =
              toString
                (
                  if constraints == null then
                    { path = metadata.versionDir; }
                  else
                    (lib.findFirst matchConstraint { path = metadata.versionDir; } constraints)
                ).path;
          in
          "${patchDir}/${p}";
      };

    versionDir =
      (toString ../.) + "/${if (gitRelease != null) then "git" else lib.versions.major release_version}";
  };
in
makeScopeWithSplicing' {
  inherit otherSplices;

  f =
    gccPackages:
    let
      callPackage = gccPackages.newScope (args // metadata);
    in
    {
      gcc = wrapCCWith {
        bintools = binutils;
        cc = gccPackages.gcc-unwrapped;

        extraPackages = [
          targetGccPackages.libgcc
        ];

        libcxx = targetGccPackages.libstdcxx;

        nixSupport.cc-cflags = [
          "-B${targetGccPackages.libgcc}/lib"
          "-B${targetGccPackages.libssp}/lib"
          "-B${targetGccPackages.libatomic}/lib"
          "-B${targetGccPackages.libgomp}/lib"
          "-I${targetGccPackages.libgomp}/lib/gcc/${metadata.release_version}/include"
        ];
      };

      gcc-unwrapped = callPackage ./gcc {
        bintools = binutils;
      };

      gccNoLibgcc = wrapCCWith {
        bintools = binutilsNoLibc;
        cc = gccPackages.gcc-unwrapped;
        extraPackages = [ ];
        libcxx = null;

        nixSupport.cc-cflags = [
          "-nostartfiles"
        ];
      };

      gccWithLibatomic = wrapCCWith {
        bintools = binutils;
        cc = gccPackages.gcc-unwrapped;

        extraPackages = [
          targetGccPackages.libgcc
        ];

        libcxx = null;

        nixSupport.cc-cflags = [
          "-B${targetGccPackages.libgcc}/lib"
          "-B${targetGccPackages.libssp}/lib"
          "-B${targetGccPackages.libatomic}/lib"
        ];
      };

      gccWithLibc = wrapCCWith {
        bintools = binutils;
        cc = gccPackages.gcc-unwrapped;

        extraPackages = [
          targetGccPackages.libgcc
        ];

        libcxx = null;

        nixSupport.cc-cflags = [
          "-B${targetGccPackages.libgcc}/lib"
        ];
      };

      gccWithLibssp = wrapCCWith {
        bintools = binutils;
        cc = gccPackages.gcc-unwrapped;

        extraPackages = [
          targetGccPackages.libgcc
        ];

        libcxx = null;

        nixSupport.cc-cflags = [
          "-B${targetGccPackages.libgcc}/lib"
          "-B${targetGccPackages.libssp}/lib"
        ];
      };

      gfortran = wrapCCWith {
        bintools = binutils;
        cc = gccPackages.gfortran-unwrapped;

        extraPackages = [
          targetGccPackages.libgcc
        ];

        libcxx = targetGccPackages.libstdcxx;

        nixSupport.cc-cflags = [
          "-B${targetGccPackages.libgcc}/lib"
          "-B${targetGccPackages.libssp}/lib"
          "-B${targetGccPackages.libatomic}/lib"
          "-B${targetGccPackages.libgomp}/lib"
          "-B${targetGccPackages.libgfortran}/lib/"
        ];
      };

      gfortran-unwrapped = gccPackages.gcc-unwrapped.override {
        langFortran = true;
        stdenv = overrideCC stdenv buildGccPackages.gcc;
      };

      gfortranNoLibgfortran = wrapCCWith {
        bintools = binutils;
        cc = gccPackages.gfortran-unwrapped;

        extraPackages = [
          targetGccPackages.libgcc
        ];

        libcxx = targetGccPackages.libstdcxx;

        nixSupport.cc-cflags = [
          "-B${targetGccPackages.libgcc}/lib"
          "-B${targetGccPackages.libssp}/lib"
          "-B${targetGccPackages.libatomic}/lib"
          "-B${targetGccPackages.libgomp}/lib"
          "-I${targetGccPackages.libgomp}/lib/gcc/${metadata.release_version}/include"
        ];
      };

      libatomic = callPackage ./libatomic {
        stdenv = overrideCC stdenv buildGccPackages.gccWithLibssp;
      };

      libbacktrace = callPackage ./libbacktrace { };

      libgcc = callPackage ./libgcc {
        stdenv = overrideCC stdenv buildGccPackages.gccNoLibgcc;
      };

      libgfortran = callPackage ./libgfortran {
        gfortran = buildGccPackages.gfortranNoLibgfortran;
        stdenv = overrideCC stdenv buildGccPackages.gcc;
      };

      libgomp = callPackage ./libgomp {
        stdenv = overrideCC stdenv buildGccPackages.gccWithLibatomic;
      };

      libiberty = callPackage ./libiberty { };
      libquadmath = callPackage ./libquadmath { };
      libsanitizer = callPackage ./libsanitizer { };

      libssp = callPackage ./libssp {
        stdenv = overrideCC stdenv buildGccPackages.gccWithLibc;
      };

      libstdcxx = callPackage ./libstdcxx {
        stdenv = overrideCC stdenv buildGccPackages.gccWithLibatomic;
      };

      stdenv = overrideCC stdenv gccPackages.gcc;
    };
}
