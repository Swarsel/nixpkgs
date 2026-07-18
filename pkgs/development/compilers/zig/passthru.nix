{
  stdenv,
  callPackage,
  overrideCC,
  wrapBintoolsWith,
  wrapCCWith,
  zig,
}:
{
  bintools = wrapBintoolsWith { bintools = zig.bintools-unwrapped; };
  bintools-unwrapped = callPackage ./bintools.nix { inherit zig; };

  cc = wrapCCWith {
    bintools = zig.bintools;
    cc = zig.cc-unwrapped;
    extraPackages = [ ];

    nixSupport.cc-cflags = [
      "-target"
      "${stdenv.targetPlatform.system}-${stdenv.targetPlatform.parsed.abi.name}"
    ];
  };

  cc-unwrapped = callPackage ./cc.nix { inherit zig; };
  fetchDeps = callPackage ./fetcher.nix { inherit zig; };
  # Provided for backward compatibility, as the `zig` derivation now sets
  # setupHook.
  hook = zig;
  stdenv = overrideCC stdenv zig.cc;
}
