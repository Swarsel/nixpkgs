{
  lib,
  stdenv,
  buildPackages,
  config,
  generateSplicesForMkScope,
  libc,
  makeScopeWithSplicing',
  newScope,
  overrideCC,
  pkgsHostTarget,
  stdenvNoLibc,
}:

makeScopeWithSplicing' {
  f =
    self:
    let
      inherit (self) callPackage;
    in
    {
      # FIXME untested with llvmPackages_16 was using llvmPackages_8
      crossThreadsStdenv = overrideCC stdenvNoLibc (
        if stdenv.hostPlatform.useLLVM or false then
          buildPackages.llvmPackages.clangNoLibcxx
        else
          buildPackages.gccWithoutTargetLibc.override (old: {
            bintools = old.bintools.override {
              libc = pkgsHostTarget.libc;
              nativeLibc = false;
              noLibc = libc == null;
            };

            libc = pkgsHostTarget.libc;
            nativeLibc = false;
            noLibc = libc == null;
          })
      );

      dlfcn = callPackage ./dlfcn { };
      libgnurx = callPackage ./libgnurx { };
      mcfgthreads = callPackage ./mcfgthreads { stdenv = self.crossThreadsStdenv; };

      mingw_w64 = callPackage ./mingw-w64 {
        stdenv = stdenvNoLibc;
      };

      mingw_w64_headers = callPackage ./mingw-w64/headers.nix { };
      npiperelay = callPackage ./npiperelay { };
      pthreads = callPackage ./mingw-w64/pthreads.nix { stdenv = self.crossThreadsStdenv; };
      sdk = callPackage ./msvcSdk { };
    }
    // lib.optionalAttrs config.allowAliases {
      mingw_w64_pthreads = lib.warn "windows.mingw_w64_pthreads is deprecated, windows.pthreads should be preferred" self.pthreads;
    };

  otherSplices = generateSplicesForMkScope "windows";
}
