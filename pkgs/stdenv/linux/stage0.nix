{
  lib,
  bootstrapFiles,
  config,
  localSystem,
}:
let
  minbootSupportedSystems = [
    "i686-linux"
    "x86_64-linux"
  ];
  minbootSupported = builtins.elem localSystem.system minbootSupportedSystems;
in
if minbootSupported then
  let
    callPackage = lib.callPackageWith { inherit lib config; };
    minimal-bootstrap = lib.recurseIntoAttrs (
      import ../../os-specific/linux/minimal-bootstrap {
        inherit lib config;
        buildPlatform = localSystem;
        checkMeta = callPackage ../generic/check-meta.nix { };

        fetchurl = import ../../build-support/fetchurl/boot.nix {
          inherit (config) rewriteURL;
          system = localSystem;
        };

        hostPlatform = localSystem;
      }
    );
    compilerPackage =
      if localSystem.libc == "glibc" then
        minimal-bootstrap.gcc-glibc
      else if localSystem.libc == "musl" then
        minimal-bootstrap.gcc-latest
      else
        throw "Can't bootstrap on ${localSystem.config}";
    libcPackage =
      if localSystem.libc == "glibc" then
        minimal-bootstrap.glibc
      else if localSystem.libc == "musl" then
        minimal-bootstrap.musl-static
      else
        throw "Can't bootstrap on ${localSystem.config}";
  in
  assert minimal-bootstrap.bash-static.passthru.isFromMinBootstrap or false; # sanity check
  {
    inherit minimal-bootstrap;
    bash = minimal-bootstrap.bash-static;

    disallowedInFinalStdenv = lib.attrsets.catAttrs "out" (
      builtins.filter (drv: lib.attrsets.isDerivation drv) (builtins.attrValues minimal-bootstrap)
    );

    dummyStdenv = {
      name = "bootstrap-stage0";

      overrides = self: super: {
        # The Glibc include directory cannot have the same prefix as the
        # GCC include directory, since GCC gets confused otherwise (it
        # will search the Glibc headers before the GCC headers).  So
        # create a dummy Glibc here, which will be used in the stdenv of
        # stage1.
        ${localSystem.libc} = self.stdenv.mkDerivation {
          pname = "bootstrap-stage0-${localSystem.libc}";
          version = "minimal-bootstrap";
          strictDeps = true;

          buildCommand = ''
            mkdir -p $out
            ln -s ${libcPackage}/lib $out/lib
            ln -s ${libcPackage}/include $out/include
          '';

          enableParallelBuilding = true;
          passthru.isFromBootstrapFiles = true;
        };

        binutils = import ../../build-support/bintools-wrapper {
          inherit lib;

          inherit (self)
            stdenvNoCC
            coreutils
            gnugrep
            libc
            ;

          bintools = minimal-bootstrap.binutils-static;
          expand-response-params = "";
          name = "bootstrap-stage0-binutils-wrapper";
          nativeLibc = false;
          nativeTools = false;
          runtimeShell = "${minimal-bootstrap.bash}/bin/bash";
        };

        # We thread stage0's stdenv through under this name so downstream stages
        # can use it for wrapping gcc too. This way, downstream stages don't need
        # to refer to this stage directly, which violates the principle that each
        # stage should only access the stage that came before it.
        ccWrapperStdenv = self.stdenv;
        coreutils = minimal-bootstrap.coreutils-static;
        gcc-unwrapped = compilerPackage;
        gnugrep = minimal-bootstrap.gnugrep-static;
      };
    };

    initialPath = with minimal-bootstrap; [
      bash-static
      binutils-static
      bzip2-static
      compilerPackage
      coreutils-static
      diffutils-static
      findutils-static
      gawk-static
      gnugrep-static
      gnumake-static
      gnupatch-static
      gnused-static
      gnutar-static
      gzip-static
      patchelf-static
      xz-static
    ];

    isMinimalBootstrap = true;
  }
else
  let
    # Download and unpack the bootstrap tools (coreutils, GCC, Glibc, ...).
    bootstrapTools = import ./bootstrap-tools {
      inherit (localSystem) libc system;
      inherit lib bootstrapFiles config;
      isFromBootstrapFiles = true;
    };
  in
  assert bootstrapTools.passthru.isFromBootstrapFiles or false; # sanity check
  {
    inherit bootstrapTools;
    bash = bootstrapTools;
    disallowedInFinalStdenv = [ bootstrapTools ];

    dummyStdenv = {
      name = "bootstrap-stage0";

      overrides = self: super: {
        # The Glibc include directory cannot have the same prefix as the
        # GCC include directory, since GCC gets confused otherwise (it
        # will search the Glibc headers before the GCC headers).  So
        # create a dummy Glibc here, which will be used in the stdenv of
        # stage1.
        ${localSystem.libc} = self.stdenv.mkDerivation {
          pname = "bootstrap-stage0-${localSystem.libc}";
          version = "bootstrap-tools";
          strictDeps = true;

          buildCommand = ''
            mkdir -p $out
            ln -s ${bootstrapTools}/lib $out/lib
          ''
          + lib.optionalString (localSystem.libc == "glibc") ''
            ln -s ${bootstrapTools}/include-glibc $out/include
          ''
          + lib.optionalString (localSystem.libc == "musl") ''
            ln -s ${bootstrapTools}/include-libc $out/include
          '';

          enableParallelBuilding = true;
          passthru.isFromBootstrapFiles = true;
        };

        binutils = import ../../build-support/bintools-wrapper {
          inherit lib;

          inherit (self)
            stdenvNoCC
            coreutils
            gnugrep
            libc
            ;

          bintools = bootstrapTools;
          expand-response-params = "";
          name = "bootstrap-stage0-binutils-wrapper";
          nativeLibc = false;
          nativeTools = false;
          runtimeShell = "${bootstrapTools}/bin/bash";
        };

        # We thread stage0's stdenv through under this name so downstream stages
        # can use it for wrapping gcc too. This way, downstream stages don't need
        # to refer to this stage directly, which violates the principle that each
        # stage should only access the stage that came before it.
        ccWrapperStdenv = self.stdenv;
        coreutils = bootstrapTools;
        gcc-unwrapped = bootstrapTools;
        gnugrep = bootstrapTools;
      };
    };

    initialPath = [ bootstrapTools ];
    isMinimalBootstrap = false;
  }
