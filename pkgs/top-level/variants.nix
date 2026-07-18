/*
  This file contains all of the different variants of nixpkgs instances.

  Unlike the other package sets like pkgsCross, pkgsi686Linux, etc., this
  contains non-critical package sets. The intent is to be a shorthand
  for things like using different toolchains in every package in nixpkgs.
*/
{
  lib,
  stdenv,
  nixpkgsFun,
  overlays,
}:
self: super: {
  pkgsArocc = nixpkgsFun {
    # Bootstrap a cross stdenv using the Aro C compiler.
    # This is currently not possible when compiling natively,
    # so we don't need to check hostPlatform != buildPlatform.
    crossSystem = stdenv.hostPlatform // {
      linker = "lld";
      useArocc = true;
    };

    overlays = [
      (self': super': {
        pkgsArocc = super';
      })
    ]
    ++ overlays;
  };

  pkgsChecked = nixpkgsFun {
    config = super.config // {
      doCheckByDefault = true;
    };
  };

  # Full package set with cuda on rocm off
  # Mostly useful for asserting pkgs.pkgsCuda.torchWithCuda == pkgs.torchWithCuda and similar
  pkgsCuda = nixpkgsFun {
    config = super.config // {
      cudaSupport = true;
      rocmSupport = false;
    };
  };

  pkgsExtraHardening = nixpkgsFun {
    overlays = [
      (
        self': super':
        {
          glibc = super'.glibc.override rec {
            enableCET = if self'.stdenv.hostPlatform.isx86_64 then "permissive" else false;
            enableCETRuntimeDefault = enableCET != false;
          };

          pkgsExtraHardening = super';

          stdenv = super'.withDefaultHardeningFlags (
            super'.stdenv.cc.defaultHardeningFlags
            ++ [
              "shadowstack"
              "nostrictaliasing"
              "pacret"
              "glibcxxassertions"
              "libcxxhardeningextensive"
              "trivialautovarinit"
            ]
          ) super'.stdenv;
        }
        // lib.optionalAttrs (with super'.stdenv.hostPlatform; isx86_64 && isLinux) {
          # causes shadowstack disablement
          pcre = super'.pcre.override { enableJit = false; };
          pcre-cpp = super'.pcre-cpp.override { enableJit = false; };
        }
      )
    ]
    ++ overlays;
  };

  # `pkgsForCudaArch` maps each CUDA capability in _cuda.db.cudaCapabilityToInfo to a Nixpkgs variant configured for
  # that target system. For example, `pkgsForCudaArch.sm_90a.python3Packages.torch` refers to PyTorch built for the
  # Hopper architecture, leveraging architecture-specific features.
  # NOTE: Not every package set is supported on every architecture!
  # See `Using pkgsForCudaArch` in doc/languages-frameworks/cuda.section.md for more information.
  pkgsForCudaArch = lib.listToAttrs (
    lib.map (cudaCapability: {
      name = self._cuda.lib.mkRealArchitecture cudaCapability;

      value = nixpkgsFun {
        config = super.config // {
          cudaCapabilities = [ cudaCapability ];
          # Not supported by architecture-specific feature sets, so disable for all.
          # Users can choose to build for family-specific feature sets if they wish.
          cudaForwardCompat = false;
          cudaSupport = true;
          rocmSupport = false;
        };
      };
    }) (lib.attrNames self._cuda.db.cudaCapabilityToInfo)
  );

  pkgsLLVM = nixpkgsFun {
    # Bootstrap a cross stdenv using the LLVM toolchain.
    # This is currently not possible when compiling natively,
    # so we don't need to check hostPlatform != buildPlatform.
    crossSystem = stdenv.hostPlatform // {
      linker = "lld";
      useLLVM = true;
    };

    overlays = [
      (self': super': {
        pkgsLLVM = super';
      })
    ]
    ++ overlays;
  };

  # All packages built with the Musl libc. This will override the
  # default GNU libc on Linux systems. Non-Linux systems are not
  # supported. 32-bit is also not supported, except for x86.
  pkgsMusl =
    if stdenv.hostPlatform.isLinux && (stdenv.buildPlatform.is64bit || stdenv.buildPlatform.isx86) then
      nixpkgsFun {
        ${if stdenv.hostPlatform == stdenv.buildPlatform then "localSystem" else "crossSystem"} = {
          config = lib.systems.parse.tripleFromSystem (
            lib.systems.parse.mkMuslSystem stdenv.hostPlatform.parsed
          );
        };

        overlays = [
          (self': super': {
            pkgsMusl = super';
          })
        ]
        ++ overlays;
      }
    else
      throw "Musl libc only supports 64-bit Linux systems, and i686-linux.";

  pkgsParallel = nixpkgsFun {
    config = super.config // {
      enableParallelBuildingByDefault = true;
    };
  };

  # Full package set with rocm on cuda off
  # Mostly useful for asserting pkgs.pkgsRocm.torchWithRocm == pkgs.torchWithRocm and similar
  pkgsRocm = nixpkgsFun {
    config = super.config // {
      cudaSupport = false;
      rocmSupport = true;
    };
  };

  pkgsStrict = nixpkgsFun {
    config = super.config // {
      strictDepsByDefault = true;
    };
  };

  pkgsStructured = nixpkgsFun {
    config = super.config // {
      structuredAttrsByDefault = true;
    };
  };

  pkgsZig = nixpkgsFun {
    # Bootstrap a cross stdenv using the Zig toolchain.
    # This is currently not possible when compiling natively,
    # so we don't need to check hostPlatform != buildPlatform.
    crossSystem = stdenv.hostPlatform // {
      linker = "lld";
      useZig = true;
    };

    overlays = [
      (self': super': {
        pkgsZig = super';
      })
    ]
    ++ overlays;
  };
}
