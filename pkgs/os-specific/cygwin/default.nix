{
  generateSplicesForMkScope,
  makeScopeWithSplicing',
}:

let
  otherSplices = generateSplicesForMkScope "cygwin";
in
makeScopeWithSplicing' {
  inherit otherSplices;

  f =
    self:
    let
      callPackage = self.callPackage;
    in
    {
      cygwinDllLinkHook = callPackage ./cygwin-dll-link-hook { };
      newlib-cygwin = callPackage ./newlib-cygwin { };
      newlib-cygwin-headers = callPackage ./newlib-cygwin { headersOnly = true; };
      # this is here to avoid symlinks being made to cygwin1.dll in /nix/store
      newlib-cygwin-nobin = callPackage ./newlib-cygwin/nobin.nix { };
      w32api = callPackage ./w32api { };
      w32api-headers = callPackage ./w32api { headersOnly = true; };
    };
}
