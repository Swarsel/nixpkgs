{
  lib,
  fetchCrate,
  makeWrapper,
  rustPlatform,
  wasm-pack,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "perseus-cli";
  version = "0.3.1";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-IYjLx9/4oWSXa4jhOtGw1GOHmrR7LQ6bWyN5zbOuEFs=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-9McjhdS6KrFgtWIaP0qKsUYpPxGQjNX7SM9gJ/aJGwc=";

  postInstall = ''
    wrapProgram $out/bin/perseus \
      --prefix PATH : "${lib.makeBinPath [ wasm-pack ]}"
  '';

  meta = {
    description = "High-level web development framework for Rust with full support for server-side rendering and static generation";
    homepage = "https://framesurge.sh/perseus/en-US";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ max-niederman ];
    mainProgram = "perseus";
  };
})
