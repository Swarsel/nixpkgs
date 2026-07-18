{
  lib,
  fetchFromSourcehut,
  kak-tree-sitter-unwrapped,
  nix-update-script,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kak-tree-sitter-unwrapped";
  version = "3.2.2";

  src = fetchFromSourcehut {
    owner = "~hadronized";
    repo = "kak-tree-sitter";
    rev = "kak-tree-sitter-v${finalAttrs.version}";
    hash = "sha256-RzPfQstjHdfLH6cF6KuMXB/J7UeR9DeJRypnGdb89TQ=";
  };

  cargoHash = "sha256-5hCBFQsZpUyPlgO/iUmBXmdcC5ceG1w4IiB27oBxRxQ=";

  passthru = {
    tests.version = testers.testVersion { package = kak-tree-sitter-unwrapped; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Server that interfaces tree-sitter with kakoune";
    homepage = "https://git.sr.ht/~hadronized/kak-tree-sitter";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ lelgenio ];
    mainProgram = "kak-tree-sitter";
  };
})
