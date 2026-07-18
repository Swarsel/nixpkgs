{
  lib,
  stdenv,
  mimalloc,
  mkMesonExecutable,
  nix-cmd,
  nix-expr,
  nix-main,
  nix-store,
  # Configuration Options
  version,
  # Whether to link against mimalloc for malloc override.
  # Significantly improves evaluation performance on allocation-heavy
  # workloads (~10-15% on large evaluations).
  withMimalloc ? !stdenv.hostPlatform.isWindows,
}:

mkMesonExecutable (finalAttrs: {
  inherit version;
  pname = "nix";

  buildInputs = [
    nix-store
    nix-expr
    nix-main
    nix-cmd
  ]
  ++ lib.optional ((lib.versionAtLeast version "2.35pre") && withMimalloc) mimalloc;

  mesonFlags = lib.optionals (lib.versionAtLeast version "2.35pre") [
    (lib.mesonEnable "mimalloc" withMimalloc)
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    mainProgram = "nix";
  };

})
