{
  lib,
  stdenv,
  fetchFromGitHub,
  replaceVars,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lalrpop";
  version = "0.22.2";

  src = fetchFromGitHub {
    owner = "lalrpop";
    repo = "lalrpop";
    rev = finalAttrs.version;
    hash = "sha256-/mk4sTgwxBrB+LEBbWv4OQEEh2P2KVSh6v5ry9/Et4s=";
  };

  patches = [
    (replaceVars ./use-correct-binary-path-in-tests.patch {
      target_triple = stdenv.hostPlatform.rust.rustcTarget;
    })
  ];

  cargoHash = "sha256-3Lm25X2QQQ4+3Spe6Nz5PkIvFcgwHQ+hqAdjsFesgro=";

  # there are some tests in lalrpop-test and some in lalrpop
  checkPhase = ''
    buildAndTestSubdir=lalrpop-test cargoCheckHook
    cargoCheckHook
  '';

  buildAndTestSubdir = "lalrpop";

  meta = {
    description = "LR(1) parser generator for Rust";
    homepage = "https://github.com/lalrpop/lalrpop";
    changelog = "https://github.com/lalrpop/lalrpop/blob/${finalAttrs.src.rev}/RELEASES.md";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [ chayleaf ];
    mainProgram = "lalrpop";
  };
})
