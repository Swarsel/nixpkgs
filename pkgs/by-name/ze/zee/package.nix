{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zee";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "zee-editor";
    repo = "zee";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/9SogKOaXdFDB+e0//lrenTTbfmXqNFGr23L+6Pnm8w=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-auwbpavF/WZQIE/htYXJ4di6xoRtXkBBkP/Bj4lFp6U=";
  # disable downloading and building the tree-sitter grammars at build time
  # grammars can be configured in a config file and installed with `zee --build`
  # see https://github.com/zee-editor/zee#syntax-highlighting
  env.ZEE_DISABLE_GRAMMAR_BUILD = 1;

  cargoPatches = [
    # fixed upstream but unreleased
    ./update-ropey-for-rust-1.65.diff
  ];

  meta = {
    description = "Modern text editor for the terminal written in Rust";
    homepage = "https://github.com/zee-editor/zee";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ booklearner ];
    mainProgram = "zee";
  };
})
